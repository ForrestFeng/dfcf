import xlrd
import glob
import os
import csv
import json
from mssql import MSSQL

MS = MSSQL(host="localhost", user="sa", pwd="Health123", db="Dfcf")


def bulk_query(csv_fn):
    basename = os.path.basename(csv_fn)
    data_name = basename[20:basename.index('.')]
    if '1Day.zjlx' in basename:
        data_name = '1DAY'

    return r"""BULK INSERT [dbo].[{table}]
    FROM  '{csv}'
    WITH
    (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
    )
    """.format(table=data_name, csv=csv_fn)


def get_header(data_name):
    table = {
        'GGPM': ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'RP', 'V', 'NewV', 'BP', 'SP', 'RR', 'ER', 'A', 'PE', 'Ind', 'H',
                 'L', 'O',
                 'LC', 'VIX', 'VR', 'OrdR', 'OrdD', 'AvgP', 'IVol', 'OVol', 'IOVolR', 'B1V', 'S1V', 'PB', 'TS', 'TSC',
                 'MS',
                 'MSC', 'R3', 'R6', 'ER3', 'ER6'],
        'ZJLX': ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'InNet', 'AA', 'TDI', 'TDO', 'TDN', 'TDP', 'DI', 'DO', 'DN', 'DP',
                 'MI', 'MO', 'MN', 'MP', 'SI', 'SO', 'SN', 'SP'],
        'ZCPM': ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'Ind', 'WPct', 'Rnk', 'RnkChg', 'R1', 'WPct3', 'Rnk3', 'RnkChg3',
                 'R3', 'WPct5', 'Rnk5', 'RnkChg5', 'R5', 'WPct10', 'Rnk10', 'RnkChg10', 'R10'],
        'DDE': ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'DDX', 'DDY', 'DDZ', 'DDX5', 'DDY5', 'DDX10', 'DDY10', 'LX', 'D5',
                'D10', 'TDS', 'TDB', 'TDN', 'DB', 'DS', 'DN'],
        'INDEX': ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'RP', 'A', 'H', 'L', 'O', 'LC'],
        'CWSJ': ['DT', 'Ordi', 'S', 'N', 'RptDate', 'TSC', 'ASC', 'SharePerPerson', 'EPS', 'NAPS', 'ROE', 'Rev', 'RevYoy',
                 'Profit', 'InvestProfit', 'TotalProfit', 'NetProfit', 'NetProfitYoy', 'UndisProfit',
                 'UndisProfitPerShare', 'MarginRate', 'TotalAssets', 'CurrentAssets', 'FixedAssets', 'IntangibleAssets',
                 'TotalLiabilities', 'CurrentLiabilities', 'LongtermLiabilities', 'LiabilityAssetRatio', 'Equity',
                 'EquityRatio', 'ReserveFunds', 'ReserveFundsPerShare', 'BSC', 'HSC', 'IPODate'],
        '1DAY': ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'InNet', 'InNetP', 'TDN', 'TDP', 'DN', 'DP', 'MN', 'MP',  'SN', 'SP']
    }
    return table[data_name]


def read_data_from_web_zjlx(web_zjlx_fn):
    """Parse zjlx  file and call your callback(ZjlxRecord) for each record
    """
    jason_data = None  #the json data
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
    with open(web_zjlx_fn, encoding='utf8') as f:
        ss = f.read().split('=')
        if len(ss) == 2:
            # add quote mark so that it becomes a valid python's json data
            s = ss[1].replace('data', '"data"').replace('date', '"date"').replace('pages', '"pages"')
            jason_data = json.loads(s)
        else:
            print('Error to parse', web_zjlx_fn)

    date_str = os.path.basename(web_zjlx_fn)[:10]
    time_str = os.path.basename(web_zjlx_fn)[11:17]
    time_str = '{}:{}:{}'.format(time_str[0:2], time_str[2:4], time_str[4:6])  #14:15:16
    dat_time_str = date_str + ' ' + time_str
    ordinal = 0
    record_list = []
    for record in jason_data["data"]:
        ordinal += 1
        record_list.append([dat_time_str, ordinal] + record.split(','))
    return record_list


def save_data_from_web_zjlx_to_csv(web_zjlx_fn):
    data_records = read_data_from_web_zjlx(web_zjlx_fn)
    out_csv_fn = web_zjlx_fn + ".csv"
    print(web_zjlx_fn, end=' -->')
    with open(out_csv_fn, 'wt', newline='') as csvfile:
        writer = csv.writer(csvfile)
        # write the header
        basename = os.path.basename(web_zjlx_fn)
        data_name = basename[18:basename.index('.')].upper()
        writer.writerow(get_header(data_name))
        # write the records
        for record in data_records:
            writer.writerow(record)
    print(out_csv_fn)
    return out_csv_fn

def read_data_from_xls(fname, with_header=False):
    basename = os.path.basename(fname)
    data_name = basename[20:basename.index('.')]
    date_time_str = basename[:19].replace('_', ':')

    bk = xlrd.open_workbook(fname)
    # shxrange = range(bk.nsheets)
    try:
        sh = bk.sheet_by_name("listTable")
    except:
        print("no sheet in %s named Sheet1" % fname)
        return None
    nrows = sh.nrows
    #ncols = sh.ncols
    # print("nrows %d, ncols %d" % (nrows,ncols))
    #cell_value = sh.cell_value(1, 1)

    record_list = []
    for i in range(0, nrows):
        row_data = sh.row_values(i)
        row_data.insert(0, date_time_str)
        record_list.append(row_data)
    if with_header:
        return record_list
    else:
        return record_list[1:]


def convert_record(header, record, dash_as_NULL=True):
    """
    convert the string to proper data type defined in the data base
    :param record: one record to process
    :return:
    """
    zipped_record = zip(header, record)
    new_record = [convert_field(zipped_field, dash_as_NULL) for zipped_field in zipped_record]
    # print(new_record)
    return new_record


def convert_field(zipped_field, dash_as_NULL=True):
    fieldnm, input_str = zipped_field

    if fieldnm == 'DT' or fieldnm == 'N' or fieldnm == 'Ind' or 'Date' in fieldnm:
        if input_str == '0000/00/00': #invalid date
            if dash_as_NULL:
                return 'NULL'
            else:
                return ''
        else:
            return input_str.strip()  # .encode('utf8')
    elif fieldnm == 'Ordi' or fieldnm == 'S':
        return int(input_str)
    elif '----' in input_str or '—' == input_str:
        if dash_as_NULL:
            return 'NULL'
        else:
            return ''
    elif '万亿' in input_str:
        input_str = input_str.replace('万亿', 'e12')
    elif '万' in input_str:
        input_str = input_str.replace('万', 'e4')
    elif '亿' in input_str:
        input_str = input_str.replace('亿', 'e8')
    try:
        return float(input_str)
    except Exception as e:
        raise e


def get_file_list_by_pattern(root_dir, pattern_str):
    pattern = os.path.join(root_dir, pattern_str)
    file_list = glob.glob(pattern)
    return file_list


def bulk_csv_data_to_sql_server(csv_fn):
    query = bulk_query(csv_fn)
    print(csv_fn, end=' -->')
    try:
        MS.ExecNonQuery(query)
        MS.Commit()
        print('\tMSSQLServer')
    except Exception as e:
        import time
        print("\n"+query)
        time.sleep(1)
        raise e


def save_xls_as_csv(xls_fname):
    basename = os.path.basename(xls_fname)
    data_name = basename[20:basename.index('.')]
    header = get_header(data_name)

    record_list = read_data_from_xls(xls_fname, with_header=False)
    csv_fn = xls_fname + '.csv'
    print(xls_fname, end=' -->')
    with open(csv_fn, 'wt') as f:
        f.write(','.join(header) + "\n")
        for record in record_list:
            new_record = convert_record(header, record, dash_as_NULL=False)
            temp_record = ["{}".format(field) for field in new_record]
            f.write(','.join(temp_record) + "\n")
    print('\t' + csv_fn)
    return csv_fn


def batch_save_xls_as_csv(root_dir, pattern='not-exist-pattern'):
    for xls_fn in get_file_list_by_pattern(root_dir, pattern):
        csv_fn = save_xls_as_csv(xls_fn)


def batch_bulk_csv_data_to_sql_server(root_dir, pattern='not-exist-pattern'):
    for csv_fn in get_file_list_by_pattern(root_dir, pattern):
        bulk_csv_data_to_sql_server(csv_fn)


def save_cwsj_to_sql_server(xls_fn):
    csv_fn = save_xls_as_csv(xls_fn)
    bulk_csv_data_to_sql_server(csv_fn)
    
# fname = r"D:\data\20140910\2014-09-10 09_25_15 ZJLX.xls"
# csv_fn = save_xls_as_csv(fname)
# bulk_csv_data_to_sql_server(csv_fn)


# save cwsj
if 0:
     save_cwsj_to_sql_server(r'D:\data\CWSJ\2014-06-30 08_00_00 CWSJ.xls')


# save 4 data
if 1:
    ROOT_DIR = [r"D:\data\20140910", r"D:\data\20140911", r"D:\data\20140912"]
    ROOT_DIR = [r"D:\data\20140915"]
    ROOT_DIR = []
    for r in ROOT_DIR:
        PATTERN = ["*INDEX.xls", "*DDE.xls", "*ZCPM.xls", "*ZJLX.xls", "*GGPM.xls"]
        for p in PATTERN:
            print(p)
            batch_save_xls_as_csv(r, p)
            batch_bulk_csv_data_to_sql_server(r, p+".csv")

if 1:
    root_dir = r'D:\data\webdata'
    pattern = r'*1Day.zjlx'
    file_list = glob.glob(os.path.join(root_dir, pattern))
    for web_zjlx_fn in file_list:
        out_csv_fn = save_data_from_web_zjlx_to_csv(web_zjlx_fn)
        bulk_csv_data_to_sql_server(out_csv_fn)