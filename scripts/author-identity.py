#!/usr/bin/env python3
"""Check attribution syntax against trusted policy, not model execution.

The policy uses plain YAML block lists. Quoted values, aliases, tags, and
multiline scalars are outside this restricted format.
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path


class PolicyError(ValueError):
    """The trusted policy is missing or malformed."""


class IdentityError(ValueError):
    """The identity does not satisfy the policy."""


@dataclass(frozen=True)
class Policy:
    authors: tuple[str, ...]
    trailers: tuple[str, ...] = ()
    model_domains: tuple[str, ...] = ()


MODEL_ID = re.compile(r"[a-z0-9]+(?:[.-][a-z0-9]+)*\Z", re.ASCII)
HARNESS = re.compile(r"[a-z][a-z0-9]*(?:-[a-z0-9]+)*\Z", re.ASCII)
DOMAIN_SUFFIX = ".noreply.nexus.local"
LEGACY_MODELS = {
    "claude-fable-51m": "claude-fable-5",
    "claude-opus-51m": "claude-opus-5",
}


def canonical_model_id(model: str) -> str:
    """Remove an explicit context suffix or a known historical alias."""
    model = model.removesuffix("[1m]")
    if not MODEL_ID.fullmatch(model):
        raise IdentityError(
            "model ID must use lowercase ASCII letters, digits, dots, and hyphens"
        )
    return LEGACY_MODELS.get(model, model)


def _address(identity: str) -> tuple[str, str, str]:
    if not identity or not identity.isprintable() or identity != identity.strip():
        raise IdentityError(
            "identity must contain printable text without surrounding whitespace"
        )
    match = re.fullmatch(r"([^<>]+) <([^<>\s@]+)@([^<>\s@]+)>", identity)
    if not match or not match[1].strip() or match[1] != match[1].strip():
        raise IdentityError("identity must use 'Display Name <address>'")
    return match[1], match[2], match[3]


def _model(identity: str) -> tuple[str, str]:
    name, local, domain = _address(identity)
    match = re.fullmatch(r"(.+) \(([^()]*)\)", name)
    if not match or not match[1].strip() or match[1] != match[1].strip():
        raise IdentityError(
            "model identity must include a final parenthesized model ID"
        )
    model = canonical_model_id(match[2])
    if canonical_model_id(local) != model:
        raise IdentityError("display model ID and address model ID must match")
    return domain, model


def _valid_domain(domain: str) -> bool:
    return domain.endswith(DOMAIN_SUFFIX) and bool(
        HARNESS.fullmatch(domain[: -len(DOMAIN_SUFFIX)])
    )


def parse_policy(text: str) -> Policy:
    """Parse the supported YAML subset and reject ambiguous policy data."""
    text = text.replace("\r\n", "\n")
    if any(not character.isprintable() and character != "\n" for character in text):
        raise PolicyError("policy contains a control character")
    lists: dict[str, list[str]] = {}
    section = None
    empty_sections = set()
    for number, line in enumerate(text.split("\n"), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        header = re.fullmatch(r"([a-z_]+):(?:[ ]*(\[\]))?[ ]*", line)
        if header:
            section = header[1]
            if section not in {"authors", "trailers", "model_domains"}:
                raise PolicyError(f"line {number}: unknown policy key")
            if section in lists:
                raise PolicyError(f"line {number}: duplicate policy key")
            lists[section] = []
            if header[2]:
                empty_sections.add(section)
            continue
        item = re.fullmatch(r"    - (\S(?:.*\S)?)", line)
        if not item or section is None or section in empty_sections:
            raise PolicyError(
                f"line {number}: expected a plain list entry with four spaces"
            )
        value = item[1]
        if value[0] in "[]{}&*!|>'\"%@`" or " #" in value or ": " in value:
            raise PolicyError(f"line {number}: unsupported YAML scalar")
        if value in lists[section]:
            raise PolicyError(f"line {number}: duplicate policy entry")
        lists[section].append(value)
    if not lists.get("authors"):
        raise PolicyError("policy must contain a nonempty authors list")
    for identity in lists["authors"] + lists.get("trailers", []):
        try:
            _, _, domain = _address(identity)
            if domain.lower().endswith(DOMAIN_SUFFIX):
                if not _valid_domain(domain):
                    raise IdentityError(
                        "listed model identity has an invalid harness domain"
                    )
                _model(identity)
        except IdentityError as error:
            raise PolicyError(f"invalid listed identity: {error}") from error
    if set(lists["authors"]) & set(lists.get("trailers", [])):
        raise PolicyError("an identity appears in both authors and trailers")
    if "model_domains" in lists:
        domains = lists["model_domains"]
    else:
        # Legacy policy already names its approved harnesses through authors.
        # Trailer-only aliases cannot grant author permissions.
        domains = sorted(
            {
                _address(author)[2]
                for author in lists["authors"]
                if _valid_domain(_address(author)[2])
            }
        )
    if any(not _valid_domain(domain) for domain in domains):
        raise PolicyError("model domains must use '<harness>.noreply.nexus.local'")
    return Policy(
        tuple(lists["authors"]), tuple(lists.get("trailers", [])), tuple(domains)
    )


def load_policy(path: str | Path) -> Policy:
    try:
        return parse_policy(Path(path).read_text(encoding="utf-8"))
    except (OSError, UnicodeError) as error:
        raise PolicyError(f"cannot read policy: {error}") from error


def validate_identity(policy: Policy, identity: str, *, trailer: bool = False) -> None:
    """Raise IdentityError unless the identity is valid in the selected role."""
    _address(identity)
    if identity in policy.authors:
        return
    if identity in policy.trailers:
        if trailer:
            return
        raise IdentityError("a trailer-only alias cannot be the commit author")
    domain, _ = _model(identity)
    if domain not in policy.model_domains:
        raise IdentityError("model domain is not trusted by the policy")


def identity_key(policy: Policy, identity: str) -> tuple[str, ...]:
    """Return a canonical key for a valid author or contributor identity."""
    validate_identity(policy, identity, trailer=True)
    try:
        domain, model = _model(identity)
    except IdentityError:
        return "exact", identity
    if _valid_domain(domain):
        return "model", domain, model
    return "exact", identity


def resolve_identity(policy: Policy, model: str, harness: str = "") -> str:
    """Resolve an existing identity or format one for a trusted harness."""
    model = canonical_model_id(model)
    if harness and not HARNESS.fullmatch(harness):
        raise IdentityError("harness must be a lowercase ASCII slug")
    domain = harness + DOMAIN_SUFFIX
    matches = []
    for identity in policy.authors:
        try:
            listed_domain, listed_model = _model(identity)
            if listed_model == model and (not harness or listed_domain == domain):
                matches.append(identity)
        except IdentityError:
            continue
    if len(matches) > 1:
        raise IdentityError("model and harness match multiple listed identities")
    if matches:
        return matches[0]
    if not harness:
        raise IdentityError("provide a harness for a new model identity")
    if domain not in policy.model_domains:
        raise IdentityError("model domain is not trusted by the policy")
    identity = f"{harness.title()} ({model}) <{model}@{domain}>"
    validate_identity(policy, identity)
    return identity


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("check-policy", "validate", "key", "resolve"):
        command = commands.add_parser(name, allow_abbrev=False)
        command.add_argument("--policy", required=True)
        if name in {"validate", "key"}:
            command.add_argument("--identity", required=True)
        if name == "validate":
            command.add_argument("--trailer", action="store_true")
        if name == "resolve":
            command.add_argument("--model", required=True)
            command.add_argument("--harness", default="")
    args = parser.parse_args(argv)
    try:
        policy = load_policy(args.policy)
        if args.command == "validate":
            validate_identity(policy, args.identity, trailer=args.trailer)
        elif args.command == "key":
            print(
                json.dumps(identity_key(policy, args.identity), separators=(",", ":"))
            )
        elif args.command == "resolve":
            print(resolve_identity(policy, args.model, args.harness))
    except PolicyError as error:
        print(f"author-identity: {error}", file=sys.stderr)
        return 2
    except IdentityError as error:
        print(f"author-identity: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
