import pytest
from pytest_bdd import scenarios, given, when, then, parsers

from bdd.app_simulation import AppSimulation


scenarios("features/core_journeys.feature")


@pytest.fixture()
def app_state():
    return AppSimulation()


@given("a fresh app context")
def fresh_app(app_state):
    # fixture already yields a fresh instance
    return app_state


@given(parsers.parse('the user selects "{provider}" login with scopes "{scopes}"'))
def select_provider(app_state, provider, scopes):
    scope_list = [scope.strip() for scope in scopes.split(",") if scope.strip()]
    app_state.select_provider(provider, scope_list)


@given("OAuth succeeds and identity is stored")
def oauth_success(app_state):
    if not app_state.current_provider:
        raise RuntimeError("provider not chosen")
    app_state.complete_oauth(app_state.current_provider)


@when(parsers.parse('the user opens chat and sends "{prompt}"'))
def send_chat(app_state, prompt):
    app_state.send_chat(prompt)


@then("a Claude response is rendered")
def chat_response_rendered(app_state):
    assert app_state.chat_history, "chat history should contain at least one message"


@then(parsers.parse('the session is marked authenticated with provider "{provider}"'))
def session_authenticated(app_state, provider):
    assert app_state.is_authenticated(provider)


@when("the Discord access token expires")
def expire_discord(app_state):
    app_state.expire_token("Discord")


@when("the app refreshes the token using PKCE")
def refresh_token(app_state):
    app_state.refresh_token(app_state.current_provider)


@given(parsers.parse("{provider} API token is configured"))
def set_cloud_token(app_state, provider):
    app_state.configure_cloud(provider, token=f"{provider.lower()}-test-token")


@when(parsers.parse('the user provisions a new "{size}" server in region "{region}" for "{provider}"'))
def provision_server(app_state, size, region, provider):
    app_state.provision_server(provider=provider, size=size, region=region)


@then("the server is marked ready with Claude CLI installed")
def server_ready(app_state):
    assert app_state.server is not None
    assert app_state.server.status == "ready"
    assert app_state.server.claude_cli_present is True


@then(parsers.parse('the server provider is "{provider}"'))
def server_provider(app_state, provider):
    assert app_state.server is not None
    assert app_state.server.provider == provider


@given(parsers.parse('RevenueCat offering "{identifier}" priced "{price}" is available'))
def revenuecat_offering(app_state, identifier, price):
    app_state.add_offering(identifier, price)


@given(parsers.parse('the subscription "{identifier}" has previous purchase history'))
def previous_purchase(app_state, identifier):
    app_state.mark_previous_purchase(identifier)


@when(parsers.parse('the user purchases the "{identifier}" plan'))
def purchase_plan(app_state, identifier):
    app_state.purchase_plan(identifier)


@when("the user restores purchases")
def restore_purchases(app_state):
    app_state.restore_purchases()


@then(parsers.parse('the entitlement "{identifier}" becomes active'))
def entitlement_active(app_state, identifier):
    ent = app_state.entitlements.get(identifier)
    assert ent is not None
    assert ent.status == "active"


@then(parsers.parse('billing status is "{status}"'))
def billing_status(app_state, status):
    ent = next(iter(app_state.entitlements.values()))
    assert ent.billing_status == status


@given(parsers.parse('the user stores API key credential "{value}"'))
def store_api_key(app_state, value):
    app_state.store_credential("apiKey", value)


@given(parsers.parse('the user stores auth token credential "{value}"'))
def store_auth_token(app_state, value):
    app_state.store_credential("token", value)


@when(parsers.parse('the user switches the active auth method to "{method}"'))
def switch_auth_method(app_state, method):
    app_state.select_auth_method(method)


@then(parsers.parse('the active auth method is "{method}"'))
def active_auth_method(app_state, method):
    assert app_state.current_auth_method == method


@then("the stored API key credential remains available")
def stored_api_key(app_state):
    assert app_state.has_credential("apiKey")


@then("the stored auth token credential remains available")
def stored_auth_token(app_state):
    assert app_state.has_credential("token")


@given(parsers.parse('an authenticated project workspace "{name}" exists on the server'))
def workspace_exists(app_state, name):
    app_state.create_workspace(name)
    app_state.select_provider("GitHub", ["repo"])
    app_state.complete_oauth("GitHub")


@when(parsers.parse('the user creates file "{filename}" with contents "{contents}"'))
def create_file(app_state, filename, contents):
    app_state.create_file(filename, contents)


@when("the user attempts to delete the project root")
def delete_root(app_state):
    app_state.delete_result = app_state.delete_workspace_root()


@then("the delete is rejected")
def delete_rejected(app_state):
    assert app_state.delete_result is False


@then(parsers.parse('the file remains accessible with content "{expected}"'))
def file_still_exists(app_state, expected):
    # Find the only file we created
    path, content = next(iter(app_state.files.items()))
    assert content == expected
    assert app_state.read_file(path) == expected
