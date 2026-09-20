vim9script

export var config: dict<any> = {
  "*": {"todo": ["TODO: ${description}${cursor}"]},
  "cpp": {"class": ["class ${name} {", "public:", "    ${cursor}${name}() = default;", "};"], "main": ["int main(int argc, char **argv) {", "    ${cursor}", "    return 0;", "}"]},
  "html": {"page": ["<!doctype html>", "<html lang=\"en\">", "<head><meta charset=\"utf-8\"><title>${title}</title></head>", "<body>${cursor}</body>", "</html>"]},
  "markdown": {"link": ["[${label}](${url})${cursor}"]},
  "python": {"function": ["def ${name}(${arguments}):", "    ${cursor}pass"], "main": ["if __name__ == '__main__':", "    ${cursor}main()"]},
}
