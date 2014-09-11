# read ggpm.xls and add to database

import xlrd
 
fname = r"D:\data\20140910\2014-09-10 09_25_15 GGPM.xls"
fname = r"D:\data\2014-09-09 17_15_03 GGPM.xls"

def read_data_from_ggpm_xls(fname):
    bk = xlrd.open_workbook(fname)
    shxrange = range(bk.nsheets)
    try:
        sh = bk.sheet_by_name("listTable")
    except:
        print("no sheet in %s named Sheet1" % fname)
        return None
    nrows = sh.nrows
    ncols = sh.ncols
    print("nrows %d, ncols %d" % (nrows,ncols))
 
    cell_value = sh.cell_value(1, 1)
    print (cell_value)
 
    row_list = []
    for i in range(0, nrows):
        row_data = sh.row_values(i)
        row_list.append(row_data)

    return row_list

def convert_field(zipped_field):
    fieldnm, input_str = zipped_field

    if fieldnm == 'N' or fieldnm  == 'Ind':
        return input_str.strip()#.encode('utf8')
    elif fieldnm == 'Ordi' or fieldnm == 'S':
        return int(input_str)

    if '万亿' in input_str:
        input_str = input_str.replace('万亿', 'e12')
    elif '万' in input_str:
        input_str = input_str.replace('万', 'e4')
    elif '亿' in input_str:
        input_str = input_str.replace('亿', 'e8')
    elif '----' in input_str:
        return 'NULL'
    return float(input_str)


def convert_record(datetimestr, header, record):
    """
    convert the string to proper data type defined in the data base
    :param record: one record to process
    :return:
    """
    zipped_record = zip(header, record)
    new_record = [convert_field(zipped_field) for zipped_field in zipped_record]
    new_record.insert(0, datetimestr)
    #print(new_record)
    return new_record


header = ['Ordi', 'S', 'N', 'P', 'R', 'RP', 'V', 'NewV', 'BP', 'SP', 'RR', 'ER', 'A', 'PE', 'Ind', 'H', 'L', 'O', 'LC', 'VIX', 'VR', 'OrdR', 'OrdD', 'AvgP', 'IVol', 'OVol', 'IOVolR', 'B1V', 'S1V', 'PB', 'TS', 'TSC', 'MS', 'MSC', 'R3', 'R6', 'ER3', 'ER6']
record = ['1', '603183', 'N亚邦', '29.51', '44.02', '9.02', '1873', '10', '29.51', '----', '0.00', '0.26', '551万', '10.77', ' 化工行业', '29.51', '24.59', '24.59', '20.49', '24.01', '----', '100.00', '23.7万', '29.43', '1868', '5', '373.60', '23.5万', '0', '3.42', '2.88亿', '85.0亿', '7200万', '21.2亿', '0.00', '0.00', '0.26', '0.26']

new_record = convert_record('2014-09-09 12:13:14', header, record)

from mssql import MSSQL

query = '''INSERT INTO [Dfcf].[dbo].[GGPM]
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




row_list = read_data_from_ggpm_xls(fname)
#print(row_list[0])
#print(row_list[1])

for record in row_list[1:]:
    new_record = convert_record('2014-09-09 12:13:14', header, record)
    ms = MSSQL(host="localhost", user="sa", pwd="Health123", db="Dfcf")
    fquery = query.format(*tuple(new_record))
    #print(fquery)
    ms.ExecNonQuery(fquery)