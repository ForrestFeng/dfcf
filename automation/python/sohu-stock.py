import distutils.file_util
import sys
import os
import time
import datetime
import urllib.request


#sample url request
#'http://q.stock.sohu.com/hisHq?code=cn_300228&start=20140710&end=20140801&stat=1&order=D&period=d&callback=historySearchHandler&rt=jsonp'


# ref http://blog.sina.com.cn/s/blog_7ed3ed3d0101foih.html
# code           股票代码，格式 国别_代码

# sd  start date 开始日期  格式 YYYYMMDD

# ed  end date   结束日期  格式 YYYYMMDD

# t   周期   d 日  w 周  m 月

# res response  返回格式，默认js。返回json格式

# symbol sample 600000
# start, end could be number like 20140728 or string like '20140728'
def getHistoryQuoteUrl(symbol_list, start, end, cycle='d', contry='cn'):
    urlPattern = 'http://q.stock.sohu.com/hisHq?code=%s&start=%s&end=%s&stat=1&order=D&period=%s&callback=historySearchHandler&rt=jsonp'
    asks = []
    for symbol in symbol_list :
        asks.append("%s_%s" % (contry, symbol))
    return urlPattern % (','.join(asks), start,end, cycle)


def getHistoryQuoteData(symbol_list, start, end, cycle='d', contry='cn', encoding='gb2312'):
    url = getHistoryQuoteUrl(symbol_list, str(start), str(end), cycle, contry)
    print(url)
    f = urllib.request.urlopen(url)
    ret = f.read().decode(encoding)
    return ret

 # sample http://hq.sinajs.cn/list=sz002124,sh600222,sh600333
def getRealQuoteUrl(symbol_list):
    base = 'http://hq.sinajs.cn/list='
    asks = []
    for symbol in symbol_list:
        market = 'sh'
        if str(symbol)[0] == '0' or str(symbol)[0] == '3':
            market = 'sz'

        asks.append("%s%s" % (market, symbol))

    return base + ','.join(asks)


def getRealQuoteData(symbol_list, encoding = 'gb2312' ):

    try:
        url = getRealQuoteUrl(symbol_list)
        f = urllib.request.urlopen(url)
        ret =  f.read().decode(encoding)
        return ret
    except Exception as e:
        print('try second time', e)
        try:
            time.sleep(2)
            url = getRealQuoteUrl(symbol_list)
            f = urllib.request.urlopen(url)
            ret =  f.read().decode(encoding)
            return ret
        except Exception as e:
            print('try third time', e)
            try:
                time.sleep(2)
                url = getRealQuoteUrl(symbol_list)
                f = urllib.request.urlopen(url)
                ret =  f.read().decode(encoding)
                return ret
            except Exception as e:
                print('try fourth time', e)
                try:
                    time.sleep(2)
                    url = getRealQuoteUrl(symbol_list)
                    f = urllib.request.urlopen(url)
                    ret =  f.read().decode(encoding)
                    return ret
                except Exception as e:
                    print('try fifth time', e)
                    try:
                        time.sleep(2)
                        url = getRealQuoteUrl(symbol_list)
                        f = urllib.request.urlopen(url)
                        ret =  f.read().decode(encoding)
                        return ret
                    except Exception as e:
                        print('give up')
                        raise e


# sortType: number 0~10\?
# sortRule: if eval to True sort desend, else asend
# page: number show which page
# pageSize: number how many row per page
# nDays: how manay days to calculate. you can see 1/3/5/10 day(s) on the http://data.eastmoney.com/zjlx/detail.html
def getZjlxUrl(sortType, sortRule, page, pageSize, nDays):
    #sample
    # http://datainterface.eastmoney.com/EM_DataCenter/JS.aspx?type=FF&sty=HFF&st=4&sr=false&p=1&ps=50&js=var%20yfiEgzRX={pages:(pc),date:%22(ud)%22,data:[(x)]}&mkt=1&stat=1&rt=46896682
    # use format function %s not work, note the {{pages: }}
    urlPattern = r'http://datainterface.eastmoney.com/EM_DataCenter/JS.aspx?type=FF&sty=HFF&st={0}&sr={1}&p={2}&ps={3}&js=var%20yfiEgzRX={{pages:(pc),date:%22(ud)%22,data:[(x)]}}&mkt=1&stat={4}'
    sRule = 'true'
    if not sortRule: sRule = 'false'
    return urlPattern.format(sortType, sRule, page, pageSize, nDays)

def getZjlxData(sortType, sortRule, page, pageSize, nDays):
    url = getZjlxUrl(sortType, sortRule, page, pageSize, nDays)
    f = urllib.request.urlopen(url)
    ret =  f.read().decode('utf8')
    return ret


#class ZjlxSortType:
#    self.TodayInAes = {'sortType':4, 'sortRule':True}
#    self.TodayInDec = {'sortType':4, 'sortRule':False}

def saveZjlxData(data, name):
    with open(name, 'w', encoding='utf8') as f:
        f.write(data)

def historySearchHandler(sohu_stock_data):
    ssd =  sohu_stock_data
    size = len(ssd)

    dct_list = []
    for dct in ssd:
        print( dct['status'] )
        print( dct['hq'] )
        print( len( dct['hq'] ) )



def test():
    #ret = getHistoryQuoteData(['600000', '300019'], '20140724', '20140801')
    #eval(ret)

    #ret = getRealQuoteData(['600000', '300019'], encoding = 'gb2312' )

    ret = getZjlxData(4, True, 1, 50, 1)
    saveZjlxData(ret, '2014-08-01PM Today-NetIn-Dec.data')

    ret = getZjlxData(4, False, 1, 50, 1)
    saveZjlxData(ret, '2014-08-01PM Today-NetIn-Aes.data')

    ret = getZjlxData(5, True, 1, 50, 1)
    saveZjlxData(ret, '2014-08-01PM Today-NetPercent-Dec.data')

    ret = getZjlxData(5, False, 1, 50, 1)
    saveZjlxData(ret, '2014-08-01PM Today-NetPercent-Aes.data')


    print(ret)

    input()

#
# read the zjlx data and parse it as a dict
# the dict contains
# {'pages': 1,
#  'date': '2014-08-02',
#  'data': ['600000,浦发银行,9.76,-0.41,165580000,8.42,263090000,13.38,-97510000,-4.96,-80790000,-4.11,-84790000,-4.31',
#           '000562,宏源证券,11.63,0.52,153430000,5.75,191800000,7.19,-38370000,-1.44,-92020000,-3.45,-61420000,-2.30',
#            '....'
#           ]
# }
def parseSavedZjlxData(filename):
    with open(filename, 'rt', encoding = 'utf8') as f:
        s = f.read()
        dct = eval(s.replace('var yfiEgzRX=', '').replace('pages:', '"pages":').replace('date:', '"date":').replace('data:', '"data":'))
        return dct


def getAndSaveAllZjlxData(nDays):
    # 4: sort by 净流入资金， True: 降序，1: 只显示一页，3000：单页3000条记录以的到全部数据 (实际股票大约只有2646只)
    ret = ""
    for i in range(5):
        ret = getZjlxData(4, True, 1, 3000, nDays)
        if len(ret) < 100000: # the data is too short try to get it again.
            continue
        else:
            break
    zjlxFileName = "./data/{0} {1}Day.zjlx".format( datetime.datetime.now().strftime("%Y-%m-%d %H%M%S"),  nDays) #'2014-08-03 222831 1Day.zjlx'
    saveZjlxData(ret, zjlxFileName)
    print(zjlxFileName, "is saved.")
    return zjlxFileName


def getAndSaveAllZjlxDataDaysOf1_3_5_10():
    fn1 = getAndSaveAllZjlxData(nDays = 1)
    fn3 = getAndSaveAllZjlxData(nDays = 3)
    fn5 = getAndSaveAllZjlxData(nDays = 5)
    fn10 = getAndSaveAllZjlxData(nDays = 10)
    return fn1, fn3, fn5, fn10

#
# get all real data and save it to file. the symbos records are read form zjlx data file
def getAndSaveCurrentOneDayQuoteData(infilename, outfilename):
    dct = parseSavedZjlxData(infilename)
    symbolsLength = len(dct.get('data'))
    print('[info] ', symbolsLength, ' recordes loaded form file', infilename, 'of date', dct.get('date'))
    symbols = []
    for record in dct.get('data'):
        symbol = record.split(',')[0]
        symbols.append(symbol)

    # we can not get 900 quotes at a time so lets 700 a time and join them together

    sections, reminder = symbolsLength // 700, symbolsLength % 700
    if reminder != 0:
        sections += 1

    realQuotedataList = []
    with open(outfilename, 'at', encoding='utf8') as f:
        for i in range(sections):
            #quoteurl = getRealQuoteUrl( symbols[700*i : min( 700*(i+1), symbolsLength ) ] )
            #print(quoteurl)
            #print('*' * 100)
            quoteData = getRealQuoteData( symbols[700*i : min( 700*(i+1), symbolsLength ) ] , encoding = 'gb2312' )
            realQuotedataList.append(quoteData)
            print("[info] quotedata part", i, "saved to file", outfilename)
            f.write(quoteData)


def noonAction():
    # save 1,3,5,10 zjlx recodes in fn1, fn3, fn5, fn10 files
    fn1, fn3, fn5, fn10 = getAndSaveAllZjlxDataDaysOf1_3_5_10()
    # get quote for recodes in fn1, then save to fn1
    getAndSaveCurrentOneDayQuoteData(fn1, fn1.replace('.zjlx', '.quote'))


# quoteData = getRealQuoteData( ['600000','600124'], encoding = 'gb2312' )
# #print(quoteData)
# with open("test", 'wt', encoding='utf8') as f:
#     f.write(quoteData)



#
# get all real data and save it to file. the symbos records are read form zjlx data file
def getAndSaveHistoryQuoteData(infilename, outfilename, start, end):
    dct = parseSavedZjlxData(infilename)
    symbolsLength = len(dct.get('data'))
    print('[info] ', symbolsLength, ' recordes loaded form file', infilename, 'of date', dct.get('date'))
    symbols = []
    for record in dct.get('data'):
        symbol = record.split(',')[0]
        symbols.append(symbol)

    # we can not get 200 quotes at a time so lets get 190 a time and join them together
    SECTION_SIZE = 100

    sections, reminder = symbolsLength // SECTION_SIZE, symbolsLength % SECTION_SIZE
    if reminder != 0:
        sections += 1


    # set retry count
    RETRY_CNT = 3

    def savePartFile(sections, quoteDataSet = [], onebyone = False):
        for i in range(sections):
            #quoteurl = getHistoryQuoteUrl( symbols[SECTION_SIZE*i : min( SECTION_SIZE*(i+1), symbolsLength ) ] , start='20140714', end='20140801')
            #print(quoteurl)
            #print('*' * 100)
            retry = 1
            while 1:

                    print('-'*88)
                    print('*** donwload section {0}/{1}'.format(i, sections))
                    partfilename = "{0}.part{1}".format(outfilename, i)

                    if partfilename in quoteDataSet:
                        break;
                    symbolList = symbols[SECTION_SIZE*i : min( SECTION_SIZE*(i+1), symbolsLength ) ]

                    if onebyone:
                        xx, yy = len(symbolList) // 10, len(symbolList) % 10
                        if yy : xx += 1


                        for x in range(xx):
                            a, b = 10*x, min(10*(x+1), len(symbolList))
                            subList = symbolList[a:b]
                            try:
                                quoteData = getHistoryQuoteData(subList,
                                                    start, end, encoding = 'gb2312')

                                with open(partfilename, 'at', encoding='utf8') as f:
                                    f.write(quoteData)
                                print('[info] batch {0}-{1} symbols donwloaded with size {2}'.format(a,b,len(quoteData)))

                            except Exception as e:
                                print('!!! batch {0}-{1} symbols donwload error'.format(a,b))
                                for s in subList:
                                    try:
                                        quoteData = getHistoryQuoteData([s],
                                                            start, end, encoding = 'gb2312')

                                        with open(partfilename, 'at', encoding='utf8') as f:
                                            f.write(quoteData)
                                        print('[info] single symbol {0} donwloaded with size {1}'.format(s, len(quoteData)))

                                    except Exception as e:
                                        print('!!! single symbol {0} donwload error'.format(s))
                                        continue

                        quoteDataSet.append(partfilename)

                    else:
                        try:
                            quoteData = getHistoryQuoteData(symbolList,
                                                    start, end, encoding = 'gb2312')

                            print('*** quoteData size is', len (quoteData) )
                            if len(quoteData) < 300:
                                retry+=1
                                if retry < RETRY_CNT:
                                    print('!!! quote data too short, try again {0}/{1}'.format(retry, RETRY_CNT))
                                    time.sleep(10)
                                    continue
                                else:
                                    break

                            with open(partfilename, 'wt', encoding='utf8') as f:
                                f.write(quoteData)
                            quoteDataSet.append(partfilename)

                        except Exception as e:
                            retry+=1
                            if retry < RETRY_CNT:
                                print('!!! quote data get exception, try again {0}/{1}'.format(retry, RETRY_CNT))
                                time.sleep(10)
                                continue
                            else:
                                break



        return quoteDataSet

    # try to get data
    quoteDataSet = []
    import os
    for i in range(sections):
        partfilename = "{0}.part{1}".format(outfilename, i)
        if os.path.exists(partfilename):
            quoteDataSet.append(partfilename)
        else:
            continue
    print("*** already has file", quoteDataSet)

    quoteDataSet = savePartFile(sections, quoteDataSet, onebyone = False)
    quoteDataSet = savePartFile(sections, quoteDataSet, onebyone = True)

    return quoteDataSet





def afternoonAction():
    #save 1,3,5,10 zjlx recodes in fn1, fn3, fn5, fn10 files
    fn1, fn3, fn5, fn10 = getAndSaveAllZjlxDataDaysOf1_3_5_10()
    getAndSaveCurrentOneDayQuoteData(fn1, fn1.replace('.zjlx', '.quote'))
    quoteDataList = getAndSaveHistoryQuoteData(infilename = fn1,
        outfilename = fn1.replace('.zjlx', '.history'),
        start = '20140722',
        end = '20140805')

    # quoteDataSet = getAndSaveHistoryQuoteData(infilename = './data/2014-08-04 152130 1Day.zjlx',
    #     outfilename = './data/2014-08-04 152130 1Day.history',
    #     start = '20140721',
    #     end = '20140801')


#noonAction()
#afternoonAction()

# def noonAction():
#     print(datetime.datetime.now())



noonAction()
