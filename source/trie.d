import std.stdio;
import std.exception;

struct Item {
    dchar character;
    bool leaf;
    Node children;

    this(dchar character, bool leaf) {
        this.character = character;
        this.leaf = leaf;
        this.children = Node();
    }
};

struct Node {
    Item[] items;
};

class Trie {
    Node root;

    this() {
    }

    void add(string str) {
        if (str == "") {
            throw new Exception("Can't add empty string to trie");
        }
        add(&root, str, 0);
    }

    bool check(string str) {
        return check(root, str, 0);
    }

    uint size() {
        return size(root);
    }

    private {
        void add(Node* node, string str, uint index) {
            dchar character = str[index];
            bool lastCharacter = index == str.length-1;
            foreach (ref item; node.items) {
                if (item.character == character) {
                    if (lastCharacter) {
                        item.leaf = true;
                    } else {
                        add(&item.children, str, index+1);
                    }
                    return;
                }
            }
            // no entry found; create new one
            node.items.length += 1;
            node.items[node.items.length-1] = Item(character, lastCharacter);
            if (!lastCharacter) {
                add(&node.items[node.items.length-1].children, str, index+1);
            }
        }

        bool check(Node node, string str, uint index) {
            dchar character = str[index];
            bool lastCharacter = index == str.length-1;
            foreach (ref item; node.items) {
                if (item.character == character) {
                    if (lastCharacter) {
                        return item.leaf;
                    } else {
                        return check(item.children, str, index+1);
                    }
                }
            }
            return false;
        }

        uint size(Node node) {
            // TODO
            return -1;
        }
    }
};

unittest {

    auto trie = new Trie();

    assertThrown(trie.add(""));
    assert(!trie.check("a"));
    trie.add("abcd");
    assert(trie.check("abcd"));
    assert(!trie.check("a"));
    trie.add("a");
    assert(trie.check("a"));
    trie.add("a");
    trie.add("a");
    trie.add("a");
    trie.add("a");
    trie.add("a");
    assert(trie.check("a"));

    import std.file;
    import std.string;

    if (exists("/usr/share/dict/words")) {
        writeln("Testing many words");
        File file = File("/usr/share/dict/words", "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
                trie.add(line);
                trie.add(line~"abcd");
                trie.add(line~"xyz");
                trie.add(line~"what");
            }
        }

        foreach (line; lines) {
            assert(trie.check(line));
        }
        assert(!trie.check("Daniel Kullmann"));
        writeln(lines.length);
        writeln(trie.size());
    }

}
