const std = @import("std");

const Parser = @import("../../osc.zig").Parser;
const Command = @import("../../osc.zig").Command;

/// Parse OSC 7770 — Ghostty action dispatch.
/// Payload format: "action_name:param" (e.g., "goto_split:left")
pub fn parse(parser: *Parser, _: ?u8) ?*Command {
    const cap = if (parser.capture) |*c| c else {
        parser.state = .invalid;
        return null;
    };
    cap.writer.writeByte(0) catch {
        parser.state = .invalid;
        return null;
    };
    const data = cap.trailing();
    parser.command = .{
        .ghostty_action = .{
            .value = data[0 .. data.len - 1 :0],
        },
    };
    return &parser.command;
}

test "OSC 7770: ghostty_action goto_split" {
    const testing = std.testing;

    var p: Parser = .init(null);

    const input = "7770;goto_split:left";
    for (input) |ch| p.next(ch);

    const cmd = p.end(null).?.*;
    try testing.expect(cmd == .ghostty_action);
    try testing.expectEqualStrings("goto_split:left", cmd.ghostty_action.value);
}

test "OSC 7770: ghostty_action empty" {
    const testing = std.testing;

    var p: Parser = .init(null);

    const input = "7770;";
    for (input) |ch| p.next(ch);
    const cmd = p.end(null).?.*;
    try testing.expect(cmd == .ghostty_action);
    try testing.expectEqualStrings("", cmd.ghostty_action.value);
}
