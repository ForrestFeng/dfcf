import xlrd
import glob
import os
from mssql import MSSQL

MS = MSSQL(host="localhost", user="sa", pwd="Health123", db="Dfcf")


def bulk_query(csv_fn):
    basename = os.path.basename(csv_fn)
    data_name = basename[20:basename.index('.')]
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
                 'EquityRatio', 'ReserveFunds', 'ReserveFundsPerShare', 'BSC', 'HSC', 'IPODate']
    }
    return table[data_name]


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


save_cwsj_to_sql_server(r'D:\data\CWSJ\2014-06-30 08_00_00 CWSJ.xls')

ROOT_DIR = [r"D:\data\20140910", r"D:\data\20140911", r"D:\data\20140912"]
ROOT_DIR = []
for r in ROOT_DIR:
    PATTERN = ["*INDEX.xls", "*DDE.xls", "*ZCPM.xls", "*.ZJLX.xls", "*.GGPM.xls"]
    for p in PATTERN:
        batch_save_xls_as_csv(r, p)
        batch_bulk_csv_data_to_sql_server(r, p+".csv")