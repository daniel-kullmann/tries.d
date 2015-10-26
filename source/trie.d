import std.stdio;
import std.exception;
import std.conv;

class Trie {

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

    Item root = Item('0', false);

    this() {
    }

    void add(string str) {
        add(&root, str, 0);
    }

    void remove(string str) {
        remove(&root, str, 0);
    }

    bool check(string str) {
        return check(root, str, 0);
    }

    uint length() {
        return length(root);
    }

    void walker(void delegate(string value) func) {
        walker(root, "", func);
    }

    private {
        void add(Item* item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                item.leaf = true;
            } else {
                dchar character = str[index];
                foreach (ref child; item.children) {
                    if (child.character == character) {
                        add(&child, str, index+1);
                        return;
                    }
                }
                // no entry found; create new one
                item.children.length += 1;
                item.children[item.children.length-1] = Item(character, isLastCharacter);
                add(&item.children[item.children.length-1], str, index+1);
            }
        }

        bool remove(Item* item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                item.leaf = false;
                return item.children.length == 0;
            } else {
                dchar character = str[index];
                foreach (idx, ref child; item.children) {
                    if (child.character == character) {
                        bool result = remove(&child, str, index+1);
                        if (result) {
                            // delete child node
                            item.children[idx] = item.children[item.children.length-1];
                            item.children.length -= 1;
                        }
                        return item.children.length == 0;
                    }
                }
                return false;
            }
        }

        bool check(Item item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                return item.leaf;
            } else {
                dchar character = str[index];
                foreach (ref child; item.children) {
                    if (child.character == character) {
                        return check(child, str, index+1);
                    }
                }
                return false;
            }
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
    assert(trie.check("abcd"));
    assert(!trie.check("a"));

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

    uint count = 0;
    trie.walker(delegate (string value) { count += 1; });
    assert(count == trie.length());

    count = trie.length();
    trie.add("todelete");
    assert(trie.check("todelete"));
    assert(count+1 == trie.length());
    trie.remove("todelete");
    assert(!trie.check("todelete"));
    assert(count == trie.length());
}

