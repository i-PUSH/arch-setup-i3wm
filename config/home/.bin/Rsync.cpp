#include <iostream>
#include <string>
#include <vector>
#include <ext/stdio_filebuf.h>

using namespace std;

bool isSubStr(string subStr, string str) {
	if (str.find(subStr) != string::npos) return true;
	else return false;
}

string splitStr(string str, string delimiter) {
	size_t pos = str.find(delimiter);
	if (pos != std::string::npos && str.length() > pos) return str.substr(pos);
	else return "none";
}

void findBaseDir(vector<string>& allList, vector<string>& dirList) {
	for (const string line : allList) {
		string dir = splitStr(line, "|");
		if (dir.back() == '/' && ! isSubStr(dirList.back(), dir))
			dirList.push_back(dir);
	}
}

string findFirstDir(vector<string>& dirList) {
	for (const string dir : dirList)
		if (dir.back() == '/') return dir;
}

bool strInList(string str, vector<string>& dirList) {
	for (const string dir : dirList){
		if (splitStr(str, "|") == dir) return false;
		if (isSubStr(dir, str)) return true;
	}
	return false;
}

vector<string> runBashCmd(const string cmd) {
	string line;
	vector<string> output;
    FILE* outputFile = popen(cmd.c_str(), "r");

    __gnu_cxx::stdio_filebuf<char> sourcebuf(outputFile, ios::in);
    istream outputStream(&sourcebuf);

    while (getline(outputStream, line)) output.push_back(line);

    return output;
}

int main(int argc, char** argv) {
	vector<string> dirList;
	string args = string(argv[1]) + " " + argv[2] + " ";
	string notShow = "";

	for (int i = 3; i < argc; i++) {
		if (argv[i][0] == '-' && argv[i][1] == '-')
			notShow = notShow + "--exclude '" + string(argv[i]).erase(0, 2) + "' ";
		else args = args + "--exclude '" + argv[i] + "' ";
	}

	// while (getline(cin, line)) allList.push_back(line);
	vector<string> allList = runBashCmd(string("rsync -nrl --out-format='%i |%n' --delete ") + args + notShow);

	dirList.push_back(splitStr(findFirstDir(allList), "|"));
	findBaseDir(allList, dirList);

	for (const string line : allList)
		if (! strInList(line, dirList)) cout << line << endl;

	cout << "Sync? (Type: yes) : "; string query; cin >> query;
	if (query == "yes") {
		vector<string> msg = runBashCmd(string("rsync -a --delete ") + args);
		for (const string line : msg) cout << line << endl;
	}

    return 0;
}
