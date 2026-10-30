"""Build reproducible REM extracts from the neighbouring original ZIP files."""
import csv
import gzip
import hashlib
import json
import re
import shutil
import zipfile
from collections import Counter
from pathlib import Path

root = Path(__file__).resolve().parent
source = root.parent
codes_a = set(('03500346 03500347 03500402 03500348 03600100 03500367 03500349 03500290 03500300 '
               '27300926 27300927 27300928 27300929 27300930 27300931 27300932 27300933 27300934 '
               '06901500 06901600 06901700 09600297 09600298 09600299 05990035 05990036 '
               '03030101 03030102 03030103 03030104 03030350 03030110 03030330 03030340 '
               '03030120 03030130 07021900').split())
codes_p = set(('P6241110 P6241111 P6241114 P6241117 P6241118 P6241121 '
               'P6221900 P6222000 P6222100 P6223230 P6223240 P6223250').split())

def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return h.hexdigest()

def main():
    out = root / 'rem'
    out.mkdir(exist_ok=True)
    controls = []
    for year in range(2019, 2025):
        archive = source / f'SERIE_REM_{year}.zip'
        with zipfile.ZipFile(archive) as z:
            for series, codes in [('A', codes_a), ('P', codes_p)]:
                pattern = re.compile(rf'(^|/)Serie{series}[^/]*\.(csv|txt)$', re.I)
                members = [i for i in z.infolist() if pattern.search(i.filename)]
                assert len(members) == 1, (archive, series, members)
                member = members[0]
                target = out / f'REM_{year}_{series}.csv.gz'
                counts = Counter()
                totals = Counter()
                months = set()
                rows = 0
                with z.open(member) as src, gzip.open(target, 'wb') as dst:
                    header = src.readline()
                    names = header.decode('ascii').strip().split(';')
                    assert names[:7] == ['Mes', 'IdServicio', 'Ano', 'IdEstablecimiento', 'CodigoPrestacion', 'IdRegion', 'IdComuna']
                    assert names[-1] == 'Col50' and len(names) == 57
                    dst.write(header)
                    for line in src:
                        fields = line.rstrip(b'\r\n').split(b';')
                        assert len(fields) == 57, (year, series, len(fields))
                        code = fields[4].decode('ascii')
                        if code in codes:
                            dst.write(line)
                            rows += 1
                            counts[code] += 1
                            months.add(fields[0].decode('ascii'))
                            if fields[7]:
                                totals[code] += int(fields[7])
                controls.append({'year': year, 'series': series, 'source_zip': archive.name,
                                 'source_sha256': digest(archive), 'member': member.filename,
                                 'member_crc32': f'{member.CRC:08x}', 'member_bytes': member.file_size,
                                 'output': target.name, 'output_sha256': digest(target), 'rows': rows,
                                 'months': sorted(months, key=int), 'rows_by_code': dict(counts),
                                 'col01_sums_blank_as_zero': dict(totals),
                                 'requested_codes_absent': sorted(codes - counts.keys())})
                assert rows > 0 and target.stat().st_size < 50000000
                print(year, series, rows, target.stat().st_size, flush=True)
            ddir = root / 'codebook' / str(year)
            ddir.mkdir(parents=True, exist_ok=True)
            for kind in ('SA', 'SP'):
                matches = [i for i in z.infolist() if 'diccionario' in i.filename.lower()
                           and re.search(rf'\b{kind}_\d{{2}}_', i.filename, re.I)
                           and i.filename.lower().endswith(('.xlsx', '.xlsm'))]
                assert len(matches) == 1, (year, kind, [i.filename for i in matches])
                with z.open(matches[0]) as src, (ddir / Path(matches[0].filename).name).open('wb') as dst:
                    shutil.copyfileobj(src, dst)
    (root / 'controles_rem.json').write_text(json.dumps(controls, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    assert next(c for c in controls if c['year'] == 2024 and c['series'] == 'A')['col01_sums_blank_as_zero']['27300929'] == 39059
    assert next(c for c in controls if c['year'] == 2024 and c['series'] == 'A')['col01_sums_blank_as_zero']['03500290'] == 72126
    print('OK: 2024 national controls; blanks treated as zero only for sums')

if __name__ == '__main__':
    main()
