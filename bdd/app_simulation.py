from dataclasses import dataclass, field
from typing import Dict, List, Optional


@dataclass
class Identity:
    provider: str
    scopes: List[str]
    authenticated: bool = False
    access_token: Optional[str] = None


@dataclass
class ServerState:
    provider: str
    size: str
    region: str
    status: str = "provisioning"
    claude_cli_present: bool = False


@dataclass
class Entitlement:
    identifier: str
    price: str
    status: str = "inactive"
    billing_status: str = "inactive"


class AppSimulation:
    def __init__(self) -> None:
        self.identities: Dict[str, Identity] = {}
        self.current_provider: Optional[str] = None
        self.current_auth_method: Optional[str] = None
        self.credentials: Dict[str, str] = {}
        self.server: Optional[ServerState] = None
        self.entitlements: Dict[str, Entitlement] = {}
        self.previous_purchases: List[str] = []
        self.chat_history: List[str] = []
        self.workspace_root: Optional[str] = None
        self.files: Dict[str, str] = {}
        self.cloud_tokens: Dict[str, str] = {}
        self.delete_result: Optional[bool] = None

    # Authentication
    def select_provider(self, provider: str, scopes: List[str]) -> None:
        self.current_provider = provider
        self.current_auth_method = "oauth"
        self.identities[provider] = Identity(provider=provider, scopes=scopes)

    def complete_oauth(self, provider: str) -> None:
        identity = self.identities.get(provider)
        if not identity:
            raise ValueError("provider not selected")
        identity.authenticated = True
        identity.access_token = f"token-{provider.lower()}"

    def expire_token(self, provider: str) -> None:
        identity = self.identities[provider]
        identity.authenticated = False

    def refresh_token(self, provider: str) -> None:
        identity = self.identities[provider]
        identity.authenticated = True
        identity.access_token = f"token-{provider.lower()}-refreshed"

    def is_authenticated(self, provider: str) -> bool:
        identity = self.identities.get(provider)
        return bool(identity and identity.authenticated)

    def store_credential(self, kind: str, value: str) -> None:
        self.credentials[kind] = value

    def select_auth_method(self, method: str) -> None:
        self.current_auth_method = method

    def has_credential(self, kind: str) -> bool:
        return bool(self.credentials.get(kind))

    # Chat
    def send_chat(self, prompt: str) -> str:
        if not self.current_provider or not self.is_authenticated(self.current_provider):
            raise RuntimeError("not authenticated")
        reply = f"Claude responded to '{prompt}' via {self.current_provider} session"
        self.chat_history.append(reply)
        return reply

    # Cloud provisioning
    def configure_cloud(self, provider: str, token: str) -> None:
        self.cloud_tokens[provider] = token

    def provision_server(self, provider: str, size: str, region: str) -> ServerState:
        if provider not in self.cloud_tokens:
            raise RuntimeError(f"missing {provider} token")
        self.server = ServerState(provider=provider, size=size, region=region)
        # Simulate tasks finishing
        self.server.status = "ready"
        self.server.claude_cli_present = True
        return self.server

    # RevenueCat
    def add_offering(self, identifier: str, price: str) -> None:
        self.entitlements[identifier] = Entitlement(
            identifier=identifier,
            price=price,
            status="inactive",
            billing_status="inactive",
        )

    def purchase_plan(self, identifier: str) -> Entitlement:
        entitlement = self.entitlements.get(identifier)
        if not entitlement:
            raise RuntimeError("offering missing")
        entitlement.status = "active"
        entitlement.billing_status = "active"
        return entitlement

    def mark_previous_purchase(self, identifier: str) -> None:
        if identifier not in self.previous_purchases:
            self.previous_purchases.append(identifier)

    def restore_purchases(self) -> None:
        for identifier in self.previous_purchases:
            entitlement = self.entitlements.get(identifier)
            if entitlement is None:
                continue
            entitlement.status = "active"
            entitlement.billing_status = "restored"

    # Files
    def create_workspace(self, name: str) -> None:
        self.workspace_root = f"/srv/{name}"

    def create_file(self, path: str, contents: str) -> str:
        if not self.workspace_root:
            raise RuntimeError("workspace missing")
        full_path = f"{self.workspace_root}/{path}"
        self.files[full_path] = contents
        return full_path

    def delete_workspace_root(self) -> bool:
        # Reject destructive root delete
        return False

    def read_file(self, path: str) -> Optional[str]:
        return self.files.get(path)
