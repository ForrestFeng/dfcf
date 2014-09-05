"""
time_url = '2014-08-16, http://hq.sinajs.cn/list=sh600222'
response = 'var hq_str_sh600222="太龙药业,7.65,7.69,7.71,7.81,7.60,7.71,7.72,14238482,109985434,5300,7.71,25100,7.70,17550,7.69,43900,7.68,12900,7.67,22270,7.72,56300,7.73,23240,7.74,142780,7.75,22300,7.76,2014-08-15,15:03:04,00";'
sample_fields_dict = {0: '太龙药业', 1: '7.65', 2: '7.69', 3: '7.71', 4: '7.81', 5: '7.60', 6: '7.71', 7: '7.72', 8: '14238482', 9: '109985434', 10: '5300', 11: '7.71', 12: '25100', 13: '7.70', 14: '17550', 15: '7.69', 16: '43900', 17: '7.68', 18: '12900', 19: '7.67', 20: '22270', 21: '7.72', 22: '56300', 23: '7.73', 24: '23240', 25: '7.74', 26: '142780', 27: '7.75', 28: '22300', 29: '7.76', 30: '2014-08-15', 31: '15:03:04', 32: '00'}
"""

import json
import csv
import os
import glob
from datetime import datetime, timedelta

class QuoteRecord():
    _col_dict = {"code": 0,
                 "name": 1,
                 "open": 2,
                 "lastclose": 3,
                 "price": 4,
                 "high": 5,
                 "low": 6,
                 "buyprice": 7,
                 "sellprice": 8,
                 "moneysum": 9,
                 "volume": 10,
                 "buy1v": 11,
                 "buy1m": 12,
                 "buy2v": 13,
                 "buy2m": 14,
                 "buy3v": 15,
                 "buy3m": 16,
                 "buy4v": 17,
                 "buy4m": 18,
                 "buy5v": 19,
                 "buy5m": 20,
                 "sell5v": 21,
                 "sell5m": 22,
                 "sell4v": 23,
                 "sell4m": 24,
                 "sell3v": 25,
                 "sell3m": 26,
                 "sell2v": 27,
                 "sell2m": 28,
                 "sell1v": 29,
                 "sell1m": 30,
                 "date": 31,
                 "time": 32,
                 "unknown": 33}

    _l = list(_col_dict.items())
    _l.sort(key=lambda item: item[1])
    cols = [c[0] for c in _l]

    def __init__(self, recStr):
        self.ok = 0
        self._rec = recStr

        ss = self._rec.split('=')
        code = ss[0].replace('var hq_str_', '')
        self.fields = ss[1].strip('";\r\n').split(',')

        # insert the code to the first place see cols
        self.fields.insert(0, code)

        if len(self.fields) == 34:
            self.ok = 1

    def __getattr__(self, attr):
        """
        :param attr:
        :return:
        """
        if attr in self._col_dict.keys():
            if 0 < self._col_dict[attr] < 30:
                return float(self.fields[self._col_dict[attr]])
            else:
                return self.fields[self._col_dict[attr]]
        else:
            super.__getattr__(attr)


def test():
    response = 'var hq_str_sh600222="太龙药业,7.65,7.69,7.71,7.81,7.60,7.71,7.72,14238482,109985434,5300,7.71,25100,7.70,17550,7.69,43900,7.68,12900,7.67,22270,7.72,56300,7.73,23240,7.74,142780,7.75,22300,7.76,2014-08-15,15:03:04,00";'
    # response = 'var hq_str_sh200012="";'
    r = QuoteRecord(response)
    print(len(r.cols), r.cols)
    print(len(r.fields), r.fields)
    if r.ok:
        # get fields with attr
        print(r.date, r.time, r.code, r.price, r.open, end=';')
    else:
        print('***', ln)


# test()


# parse the quote record one by one, call your callback(recode) if the quote record is valid and callback is not None
def parse_quote_file(fname, callback):
    with open(fname, encoding='utf8') as f:
        for ln in f:
            r = QuoteRecord(ln)
            if r.ok:
                # get fields with attr
                #print(r.date, r.time, r.code, r.price, r.open, end=';')
                if callback: callback(r)
            else:
                print('***No Data:', ln)


def parse_quote_then_write_to_csv(infn, outfn):
    #import csv
    with open(outfn, 'wt', encoding='utf8', newline='') as csvfile:
        writer = csv.writer(csvfile)  #, delimiter=' ', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(QuoteRecord.cols)

        def process_record(r):
            writer.writerow(r.fields)

        parse_quote_file(infn, process_record)


class ZjlxRecord():
    cols = ['date',
            'time',
            'datetime',
            'ordinal',
            'symbol',
            'name',
            'price',
            #rise percentage
            'risepct',
            'leadm',
            'leadpct',
            'superm',
            'superpct',
            'bigm',
            'bigpct',
            'middlem',
            'middlepct',
            'smallm',
            'smallpct']

    def __init__(self, dateStr, timeStr, recStr, ordinal):
        '''
        dateStr eg. '2014-08-14'
        timeStr eg. '14:20:11' or empty if no time avaliable''
        recStr one record string get from zjlx file.
        '''
        self.fields = [dateStr, timeStr, dateStr + ' ' + timeStr, ordinal]
        ss = recStr.split(',')
        #ss[0] = '"{}"'.format(ss[0])
        self.fields += ss

    def __getattr__(self, attr):
        try:
            idx = self.cols.index(attr)
            if attr in ('date', 'symbol', 'name'):
                return self.fields[idx]
            else:
                return float(self.fields[idx])
        except ValueError as e:
            super.__getattr__(attr)


def parse_zjlx_file(infn, callback):
    """Parse zjlx  file and call your callback(ZjlxRecord) for each record
    """
    j = None  #the json data
    """
    loaded Json data sample:
    {"pages":1,
     "date":"2014-08-02",
     "data":[
        "600000,浦发银行,9.76,-0.41,165580000,8.42,263090000,13.38,-97510000,-4.96,-80790000,-4.11,-84790000,-4.31",
        "000562,宏源证券,11.63,0.52,153430000,5.75,191800000,7.19,-38370000,-1.44,-92020000,-3.45,-61420000,-2.30",
        "002166,莱茵生物,20.45,10.01,131410000,27.03,116990000,24.06,14420000,2.97,-73640000,-15.15,-57760000,-11.88"
        ...
        ]}
    """
    with open(infn, encoding='utf8') as f:
        ss = f.read().split('=')
        if len(ss) == 2:
            s = ss[1].replace('data', '"data"').replace('date', '"date"').replace('pages', '"pages"')
            j = json.loads(s)
        else:
            print('Error to parse', infn)
    # add the time part to
    time_str = ''
    ss = os.path.split(infn)
    t = ss[1][11:17]  #'141516'
    time_str = '{}:{}:{}'.format(t[0:2], t[2:4], t[4:6])  #14:15:16
    zipped = zip(range(len(j['data'])), j['data'])
    for z in zipped:
        r = ZjlxRecord(j['date'], time_str, z[1], z[0])
        callback(r)


def parse_zjlx_then_write_to_csv(infn, outfn, outfn_encoding):
    with open(outfn, 'wt', encoding=outfn_encoding, newline='') as csvfile:
        writer = csv.writer(csvfile)
        # write the header
        writer.writerow(ZjlxRecord.cols)

        def callback(r):
            writer.writerow(r.fields)

        parse_zjlx_file(infn, callback)


def crush_1day_zjix_to_csv(rootdir, outfn, latest_days=0, outfn_encoding='utf8', start_date=None, end_date=None):
    """
    :param rootdir: zjlx dir
    :param outfn: out put file name
    :param outfn_encoding: out put file encoding
    :param latest_days: how many zjlx data of the recent days to crushed. default to 0, crush all the zjlx files to cvs
    :param start_date:  file to parse from the day. str or date/datetime.
    :param end_date: file to parse till this day. str or date/datetime.
    :return: None
    """
    with open(outfn, 'wt', encoding=outfn_encoding, newline='') as csvfile:
        writer = csv.writer(csvfile)
        # write the header
        writer.writerow(ZjlxRecord.cols)

        def callback(r):
            writer.writerow(r.fields)

        #glob all zjlxfiles
        glob_pattern = os.path.join(rootdir, '*1Day.zjlx')
        fn_list = glob.glob(glob_pattern)

        def date_from_file_path(file_path):
            return os.path.split(file_path)[1][0:10]

        date_list = [date_from_file_path(date_str) for date_str in fn_list]
        # get unique date and sort it asc.
        unique_sorted_date_list = sorted(set(date_list))

        # recalculate the unique_sorted_date_list if start_date and end_data are valid date
        if start_date and end_date:
            try:
                sdate, edate = start_date, end_date
                if isinstance(start_date, str) and isinstance(end_date, str):
                    sdate = datetime.strptime(start_date, "%Y-%m-%d")
                    edate = datetime.strptime(end_date, "%Y-%m-%d")
                one_day = timedelta(days=1)
                unique_sorted_date_list = [sdate.strftime("%Y-%m-%d")]
                while sdate < edate:
                    sdate += one_day
                    unique_sorted_date_list += [sdate.strftime("%Y-%m-%d")]
            except ValueError:
                print("start_date or end_date does not match format '%Y-%m-%d'")

        idx = latest_days if latest_days > 0 else max(len(unique_sorted_date_list), latest_days)

        for date in unique_sorted_date_list[-idx:]:
            glob_pattern = os.path.join(rootdir, date + '*1Day.zjlx')
            fn_list = glob.glob(glob_pattern)
            for infn in fn_list:
                print('crush', infn)
                parse_zjlx_file(infn, callback)


def group_to_by_week(sorted_date_str_list, format):
    """
    :param sorted_date_str_list:
    :return:weeknum_keyed_dict{weeknum:{ weekday : date_str, ..}}
    """
    weeknum_keyed_dict = {}
    for datestr in sorted_date_str_list:
        dtm = datetime.strptime(datestr, format)
        isocalendar = dtm.isocalendar()
        if not weeknum_keyed_dict.get(isocalendar[1]):
            na = "          "
            weeknum_keyed_dict[isocalendar[1]] = {i: na for i in range(1, 8)}
        weeknum_keyed_dict[isocalendar[1]].update({isocalendar[2]: datestr})
    return weeknum_keyed_dict


def analize_captured_samples(rootdir):
    """Print how many samples captured and what captured each day.
    """
    pattern_dict = {"1Day.zjlx": "*1Day.zjlx", "3Day.zjlx": "*3Day.zjlx",
                    "5Day.zjlx": "*5Day.zjlx", "10Day.zjlx": "*10Day.zjlx",
                    "1Day.quote": "*1Day.quote"}
    file_dict = {}
    for k, v in pattern_dict.items():
        glob_pattern = os.path.join(rootdir, v)
        fn_list = glob.glob(glob_pattern)
        file_dict[k] = fn_list

    def date_from_file_path(file_path):
        return os.path.split(file_path)[1][0:10]

    start_date = datetime.strptime(date_from_file_path(file_dict["1Day.zjlx"][0]), "%Y-%m-%d")
    end_date = datetime.strptime(date_from_file_path(file_dict["1Day.zjlx"][-1]), "%Y-%m-%d")
    total_days = (end_date - start_date).days + 1
    date_list = [date_from_file_path(date_str) for date_str in file_dict["1Day.zjlx"]]
    date_set = set(date_list)

    template = """Summary：
Start Date: {start_date}
End   Date: {end_date}
Total Days: {total_days}
Trade Days: {trade_days}
Quote 1Day: {cnt_1day_quote}
Zjlx  1Day: {cnt_1day_zjlx}
Zjlx  3Day: {cnt_3day_zjlx}
Zjlx  5Day: {cnt_5day_zjlx}
Zjlx 10Day: {cnt_10day_zjlx}
"""
    summary = template.format(start_date=start_date, end_date=end_date, total_days=total_days,
                              cnt_1day_quote=len(file_dict["1Day.quote"]),
                              cnt_1day_zjlx=len(file_dict["1Day.zjlx"]),
                              cnt_3day_zjlx=len(file_dict["3Day.zjlx"]),
                              cnt_5day_zjlx=len(file_dict["5Day.zjlx"]),
                              cnt_10day_zjlx=len(file_dict["10Day.zjlx"]),
                              trade_days=len(date_set))
    print(summary)
    weeknum_keyed_dict = group_to_by_week(sorted(date_set), "%Y-%m-%d")
    for k in sorted(weeknum_keyed_dict.keys()):
        print(k, weeknum_keyed_dict[k])


    print()
    print("c(", end='')
    for k in sorted(weeknum_keyed_dict.keys()):

        for i in weeknum_keyed_dict[k].values():
            if not i.isspace():
                print('"{}"'.format(i), end=',')
    print(")", end='')


def check(r):
    if len(r.fields) != 15:
        print(r)


#parse_zjlx_file(r'M:\home\projects\dfcfpy-fast-version\data\2014-08-03 223540 1Day.zjlx', check)
#parse_quote_file(r'D:\home\projects\dfcfpy-fast-version\data\2014-08-04 115949 1Day.quote', write_to_csv)
#parse_quote_then_write_to_csv(r'D:\home\projects\dfcfpy-fast-version\data\2014-08-04 115949 1Day.quote',
#        r'D:\home\projects\dfcfpy-fast-version\data\2014-08-04 115949 1Day.quote.csv')
#parse_zjlx_then_write_to_csv(r'D:\home\projects\dfcfpy-fast-version\data\2014-08-03 223540 1Day.zjlx',
#        r'D:\home\projects\dfcfpy-fast-version\data\2014-08-03 223540 1Day.zjlx.gb2312.csv', 'gb2312')

fn_root_dir = r'D:\home\projects\dfcfpy-fast-version\data'
fn_crush_csv = r'D:\home\projects\dfcfpy-fast-version\data\generated\crushed.1Day.zjlx.csv'
latest_days = 0
start_date = datetime(2014, 8, 7)
end_date   = datetime(2014, 8, 26)

if 1:
    crush_1day_zjix_to_csv(fn_root_dir, fn_crush_csv,
                           latest_days=latest_days,
                           start_date=start_date,
                           end_date=end_date,
                           outfn_encoding='gb2312')

analize_captured_samples(fn_root_dir)
