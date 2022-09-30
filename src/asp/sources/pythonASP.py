import subprocess
import json

clingo_path = '/usr/local/bin/clingo'
#clingo_path = '/bin/clingo'
clingo_options = ['--outf=2','-n 0']
clingo_command = [clingo_path] + clingo_options

def solve(program):
    input = program.encode()
    process = subprocess.Popen(clingo_command, stdin=subprocess.PIPE, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    output, error = process.communicate(input)
    result = json.loads(output.decode())
    if result['Result'] == 'SATISFIABLE':
        return [value['Value'] for value in result['Call'][0]['Witnesses']]
    else:
        return None

