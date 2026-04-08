import Testing
@testable import CodeAgentsMobile

struct PathUtilsTests {
    @Test func expandTildeExpandsHomeDirectory() {
        #expect(PathUtils.expandTilde("~", homeDirectory: "/Users/demo") == "/Users/demo")
        #expect(
            PathUtils.expandTilde("~/Projects/CodeAgents", homeDirectory: "/Users/demo") ==
                "/Users/demo/Projects/CodeAgents"
        )
    }

    @Test func normalizeResolvesRelativeSegments() {
        #expect(PathUtils.normalize("/srv/projects/../demo/./README.md") == "/srv/demo/README.md")
        #expect(PathUtils.normalize("src/../tests/./fixtures") == "tests/fixtures")
    }

    @Test func joinAvoidsDuplicateSlashes() {
        #expect(PathUtils.join("/srv", "demo", "README.md") == "/srv/demo/README.md")
        #expect(PathUtils.join("/srv/", "/demo/", "README.md") == "/srv/demo/README.md")
    }
}
