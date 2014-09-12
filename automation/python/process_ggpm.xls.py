# read ggpm.xls and add to database

import xlrd
import glob
import os
from mssql import MSSQL


fname = r"D:\data\20140910\2014-09-10 09_25_15 GGPM.xls"
fname = r"D:\data\2014-09-11 15_01_16 GGPM.xls"
ROOT_DIR = r"D:\data"
MS = MSSQL(host="localhost", user="sa", pwd="Health123", db="Dfcf")
HEADER = ['DT', 'Ordi', 'S', 'N', 'P', 'R', 'RP', 'V', 'NewV', 'BP', 'SP', 'RR', 'ER', 'A', 'PE', 'Ind', 'H', 'L', 'O',
          'LC', 'VIX', 'VR', 'OrdR', 'OrdD', 'AvgP', 'IVol', 'OVol', 'IOVolR', 'B1V', 'S1V', 'PB', 'TS', 'TSC', 'MS',
          'MSC', 'R3', 'R6', 'ER3', 'ER6']
record = ['2014-09-11 15:01:16', '1', '603183', 'N亚邦', '29.51', '44.02', '9.02', '1873', '10', '29.51', '----', '0.00',
          '0.26', '551万', '10.77', ' 化工行业', '29.51', '24.59', '24.59', '20.49', '24.01', '----', '100.00', '23.7万',
          '29.43', '1868', '5', '373.60', '23.5万', '0', '3.42', '2.88亿', '85.0亿', '7200万', '21.2亿', '0.00', '0.00',
          '0.26', '0.26']
BULK_QUERY = r"""BULK INSERT GGPM
FROM  '{}'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n',
FIRSTROW = 2
)
"""
QUERY = '''INSERT INTO [Dfcf].[dbo].[GGPM]
           ([DT]
           ,[Ordi]
           ,[S]
           ,[N]
           ,[P]
           ,[R]
           ,[RP]
           ,[V]
           ,[NewV]
           ,[BP]
           ,[SP]
           ,[RR]
           ,[ER]
           ,[A]
           ,[PE]
           ,[Ind]
           ,[H]
           ,[L]
           ,[O]
           ,[LC]
           ,[VIX]
           ,[VR]
           ,[OrdR]
           ,[OrdD]
           ,[AvgP]
           ,[IVol]
           ,[OVol]
           ,[IOVolR]
           ,[B1V]
           ,[S1V]
           ,[PB]
           ,[TS]
           ,[TSC]
           ,[MS]
           ,[MSC]
           ,[R3]
           ,[R6]
           ,[ER3]
           ,[ER6])
     VALUES
           ('{}'
           ,{}
           ,{}
           ,'{}'
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,'{}'
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{}
           ,{})'''


def batch_read_ggmp_data(rootdir):
    pattern = os.path.join(rootdir, "*GGPM.xls")
    file_list = glob.glob(pattern)
    # print(file_list)
    total_list = []
    for fn in file_list:
        #2014-09-11 15_01_16 GGPM
        print(fn)
        record_list = read_data_from_ggpm_xls(fn)
        total_list += record_list
        print(len(total_list))
        #if len(total_list) > 2000:
        #    break
    return total_list


def save_ggpm_as_csv(xls_fname):
    record_list = read_data_from_ggpm_xls(xls_fname, with_header=False)
    csv_fn = xls_fname + '.csv'
    with open(csv_fn, 'wt') as f:
        f.write(','.join(HEADER) + "\n")
        for record in record_list:
            new_record = convert_record(HEADER, record, dash_as_NULL=False)
            temp_record = ["{}".format(field) for field in new_record]
            f.write(','.join(temp_record) + "\n")
    return csv_fn


def read_data_from_ggpm_xls(fname, with_header=False):
    date_time_str = os.path.basename(fname)[:19].replace('_', ':')
    bk = xlrd.open_workbook(fname)
    shxrange = range(bk.nsheets)
    try:
        sh = bk.sheet_by_name("listTable")
    except:
        print("no sheet in %s named Sheet1" % fname)
        return None
    nrows = sh.nrows
    ncols = sh.ncols
    # print("nrows %d, ncols %d" % (nrows,ncols))

    cell_value = sh.cell_value(1, 1)

    record_list = []
    for i in range(0, nrows):
        row_data = sh.row_values(i)
        row_data.insert(0, date_time_str)
        record_list.append(row_data)
    if with_header:
        return record_list
    else:
        return record_list[1:]


def convert_field(zipped_field, dash_as_NULL=True):
    fieldnm, input_str = zipped_field

    if fieldnm == 'DT' or fieldnm == 'N' or fieldnm == 'Ind':
        return input_str.strip()  # .encode('utf8')
    elif fieldnm == 'Ordi' or fieldnm == 'S':
        return int(input_str)
    if '----' in input_str:
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

    return float(input_str)


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


def get_file_list_by_pattern(root_dir, pattern_str):
    pattern = os.path.join(root_dir, pattern_str)
    file_list = glob.glob(pattern)
    return file_list


def bulk_ggpm_csv_to_sql_server(csv_fn):
    query = BULK_QUERY.format(csv_fn)
    MS.ExecNonQuery(query)
    MS.Commit()

def batch_save_ggpm_as_csv(root_dir):
    for xls_fn in get_file_list_by_pattern(root_dir, "*GGPM.xls"):
        print(xls_fn)
        csv_fn = save_ggpm_as_csv(xls_fn)


def batch_bulk_ggpm_csv_to_sql_server(root_dir):
    for csv_fn in get_file_list_by_pattern(root_dir, "*GGPM.xls.csv"):
        print(csv_fn)
        bulk_ggpm_csv_to_sql_server(csv_fn)


def save_records_to_sql_server(record_list):
    cnt = 0
    total = len(record_list)
    for record in record_list[1:]:
        # print(".", sep='', end='')
        new_record = convert_record(HEADER, record)
        fquery = QUERY.format(*tuple(new_record))
        #print(fquery)
        try:
            MS.ExecNonQuery(fquery)
            cnt += 1
            print("{}/{}".format(cnt, total))
        except Exception as e:
            print(new_record)
            print(e)
        if cnt % 1000 == 0:
            MS.Commit()


def show_record_list(record_list):
    print(len(record_list))


# batch_read_ggmp_data(ROOT_DIR, show_record_list)
#toto_list = batch_read_ggmp_data(ROOT_DIR)
#save_records_to_sql_server(toto_list)

#save_ggpm_as_csv(fname)
ROOT_DIR = r'D:\data\20140910'
#batch_save_ggpm_as_csv(ROOT_DIR)
batch_bulk_ggpm_csv_to_sql_server(ROOT_DIR)
