# read ggpm.xls and add to database

import xlrd
 
fname = r"D:\data\20140910\2014-09-10 09_25_15 GGPM.xls"

def read_data_from_ggpm_xls(fname):
    bk = xlrd.open_workbook(fname)
    shxrange = range(bk.nsheets)
    try:
        sh = bk.sheet_by_name("listTable")
    except:
        print ("no sheet in %s named Sheet1" % fname)
        return None
    nrows = sh.nrows
    ncols = sh.ncols
    print("nrows %d, ncols %d" % (nrows,ncols))
 
    cell_value = sh.cell_value(1,1)
    print (cell_value)
 
    row_list = []
    for i in range(0, nrows):
        row_data = sh.row_values(i)
        row_list.append(row_data)

    return row_list

row_list = read_data_from_ggpm_xls(fname)
print(row_list[0])
print(row_list[1])