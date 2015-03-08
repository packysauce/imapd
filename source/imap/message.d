import std.array;
import std.string;

class Message {
  string tag;
  string command;
  string[] args;

  this(string tag, string command, string[] args) {
    this.tag = tag;
    this.command = command;
    this.args = args;
  }

  override string toString() {
    return tag ~ " " ~ command ~ " " ~ args.join(" ");
  }

  string toDebugString() {
    return format("Tag: %s, Command: %s, Args: %s", tag, command, args);
  }

  string opCast(string) {
    return "xyz";
  }
}

Message asMessage(string message) {
  auto things = message.split();
  auto tag = things[0]; auto command = things[1]; auto args = things[2..$];
  return new Message(tag, command, args);
}
