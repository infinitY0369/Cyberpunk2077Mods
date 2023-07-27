def convert_dumped_log_to_ini(string):
    lines = string.split("\n")
    sections = {}

    for line in lines:
        line = line.strip()

        if not line:
            continue

        key_value = line.split(" = ")
        key = key_value[0].strip()
        value = key_value[1].strip()

        section_key = key.rsplit("/", 1)[0]

        if section_key not in sections:
            sections[section_key] = []

        sections[section_key].append((key, value))

    result = ""
    for section_key, keys_values in sorted(sections.items(), key=lambda x: x[0].lower()):
        result += f"[{section_key}]\n"
        for key, value in sorted(keys_values, key=lambda x: x[0].lower()):
            result += f"{key.split('/')[-1]} = {value}\n"
        result += "\n"

    return result.rstrip() + "\n"


input_file_path = "dump\\cyber_engine_tweaks.log"
output_file_path = "dump\\config.ini"

with open(input_file_path, "r", encoding="UTF-8") as input:
    input_string = input.read()

output_string = convert_dumped_log_to_ini(input_string)
with open(output_file_path, "w", encoding="UTF-8") as output:
    output.write(output_string)
