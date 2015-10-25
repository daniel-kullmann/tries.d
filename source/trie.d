import std.stdio;
import std.exception;
import std.conv;

struct Item {
    dchar character;
    bool leaf;
    Item[] children;

    this(dchar character, bool leaf) {
        this.character = character;
        this.leaf = leaf;
        this.children = [];
    }
};

class Trie {
    Item root = Item('0', false);

    this() {
    }

    void add(string str) {
        if (str == "") {
            root.leaf = true;
        } else {
            add(&root, str, 0);
        }
    }

    bool check(string str) {
        if (str == "") {
            return root.leaf;
        } else {
            return check(root, str, 0);
        }
    }

    uint length() {
        return length(root);
    }

    void walker(void delegate(string value) func) {
        walker(root, "", func);
    }

    private {
        void add(Item* item, string str, uint index) {
            dchar character = str[index];
            bool isLastCharacter = index == str.length-1;
            foreach (ref child; item.children) {
                if (child.character == character) {
                    if (isLastCharacter) {
                        child.leaf = true;
                    } else {
                        add(&child, str, index+1);
                    }
                    return;
                }
            }
            // no entry found; create new one
            item.children.length += 1;
            item.children[item.children.length-1] = Item(character, isLastCharacter);
            if (!isLastCharacter) {
                add(&item.children[item.children.length-1], str, index+1);
            }
        }

        bool check(Item item, string str, uint index) {
            dchar character = str[index];
            bool isLastCharacter = index == str.length-1;
            foreach (ref child; item.children) {
                if (child.character == character) {
                    if (isLastCharacter) {
                        return child.leaf;
                    } else {
                        return check(child, str, index+1);
                    }
                }
            }
            return false;
        }

        uint length(Item item) {
            // TODO
            uint result = 0;
            if (item.leaf) {
                result += 1;
            }
            foreach (ref child; item.children) {
                result += length(child);
            }
            return result;
        }
    
        void walker(Item item, string partialValue, void delegate(string value) func) {
            if (item.leaf) {
                func(partialValue);
            }
            foreach (ref child; item.children) {
                walker(child, partialValue ~ to!string(child.character), func);
            }


        }
    }
};

unittest {

    auto trie = new Trie();

    assert(trie.length() == 0);
    assert(!trie.check("a"));
    
    trie.add("abcd");
    uint numberOfEntries = 0;
    bool correctEntry = true;
    trie.walker(delegate (string value) { 
        numberOfEntries += 1; 
        if (value != "abcd") {
            correctEntry = false;
        }
    });
    assert(numberOfEntries == 1);
    assert(correctEntry);

    assert(trie.check("abcd"));
    assert(!trie.check("a"));

    trie.add("a");
    assert(trie.check("a"));
    assert(trie.length() == 2);
    
    trie.add("a");
    trie.add("a");
    trie.add("a");
    trie.add("a");
    trie.add("a");
    assert(trie.check("a"));

    trie.add("abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz");
    assert(trie.check("abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz"));
    

    assert(!trie.check(""));
    trie.add("");
    assert(trie.check(""));

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
            }
        }

        foreach (line; lines) {
            assert(trie.check(line));
        }
    }

    if (exists("/usr/share/dict/cracklib-small")) {
        writeln("Testing many words (2)");
        File file = File("/usr/share/dict/cracklib-small", "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
                trie.add(line);
            }
        }

        foreach (line; lines) {
            assert(trie.check(line));
        }
    }

    assert(!trie.check("Daniel Kullmann"));
    writeln(trie.length());

    uint count = 0;
    trie.walker(delegate (string value) { count += 1; });
    assert(count == trie.length());

}

