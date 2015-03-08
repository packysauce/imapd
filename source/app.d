
import vibe.d;
import std.array;
import message;

class IMAPConnection {
  string[] caps = ["IMAP4REV1"];
  TCPConnection conn;

  void announceCaps() {
    auto response = "* OK [CAPABILITY " ~ caps.join(" ") ~ "] Welcome\r\n";
    conn.write(response);
  }

  string getLine() {
    return cast(string)conn.readUntil(cast(ubyte[])"\r\n");
  }

  Message getMessage() {
    return getLine().asMessage();
  }

  this(TCPConnection conn) {
    logInfo("Connection from " ~ conn.remoteAddress.toString());
    this.conn = conn;
  }

  void handleMessage(Message msg) {
    logInfo(msg.toDebugString());
    conn.write(msg.tag ~ " OK\r\n");
  }

  void shutdown() {
    logInfo("Connection from " ~ conn.remoteAddress.toString() ~ " closed");
    conn.close();
  }

  void serve() {
    announceCaps();
    scope (exit) shutdown();
    while (true) {
      try {
        handleMessage(getMessage());
      } catch (Throwable o) {
        break;
      }
    }
  }
}

class IMAP {
  void onConnect(TCPConnection conn) {
    auto cx = new IMAPConnection(conn);
    cx.serve();
  }
}

shared static this() {
  setLogFormat(FileLogger.Format.threadTime, FileLogger.Format.threadTime);
  auto x = new IMAP();
  listenTCP(8443, &x.onConnect);
}
