0001.00       H DATFMT(*ISO)                                                                                   04/09/04
0002.00       H OPTION(*NODEBUGIO: *SRCSTMT)                                                                   04/09/04
0003.00       H DFTACTGRP(*NO)                                                                                 03/08/25
0004.00       H ACTGRP(*CALLER)                                                                                03/08/25
0005.00       H BNDDIR('PRDBNDDIR')                                                                            03/08/25
0006.00       F****************************************************************                                00/00/00
0007.00       F*  PROGRAM NAME  -  INR1031Z                         (YR2000)  *                                24/05/16
0008.00       F*  DESCRIPTION   -  CIGARETTE PO INQUIRY - ZPL                 *                                24/05/16
0009.00       F*  AUTHOR        -  STEVE FEINSTEIN                            *                                00/00/00
0010.00       F*  DATE-CREATED  -  05/16/2024                                 *                                24/05/16
0011.00       F*  NOTES         -                                             *                                00/00/00
0012.00       F*  ANY NEW PROGRAM DEFINED VARIABLES MUST BE RESET IN "FINIT". &                                00/00/00
0013.00       F****************************************************************                                00/00/00
0014.00       F*  OTHER PROGRAMS/SYSTEMS TO CONSIDER:                         *                                00/00/00
0015.00       F*   CLP INR1044 DISPLAYS CIG LABELS BY PO & ALLOWS REPRINT     *                                00/00/00
0016.00       F*   CLL INR1103 DISPLAYS CIG LABELS BY LICENSE                 *                                00/00/00
0017.00       F*       INR1405 SCANS LABELS ON PALLET & PRINTS LICENSE        *                                00/00/00
0018.00       F*       INR1089 CANCELS & REACTIVATES CIGARETTE LABELS         *                                00/00/00
0019.00       F*                                                              *                                24/05/16
0020.00       F*  ANY CHANGES MADE TO THIS PROGRAM SHOULD BE ALSO MADE IN     *                                24/09/19
0021.00       F*  INR1031 - CPI - Cigarette PO Inquiry                        *                                24/09/19
0022.00       F*                                                              *                                24/05/16
0023.00       F****************************************************************                                00/00/00
0024.00       F* HOW PROGRAM FUNCTIONS:                                       *                                00/00/00
0025.00       F*                                                              *                                00/00/00
0026.00       F* PROGRAM ALLOWS DEPOT USERS TO VIEW CIGARETTE PO'S, PRINT     *                                00/00/00
0027.00       F* CIGARETTE LABELS FOR THOSE PO'S AND CANCEL LABEL PRINT FOR   *                                00/00/00
0028.00       F* THOSE PO'S.                                                  *                                00/00/00
0029.00       F*                                                              *                                00/00/00
0030.00       F* THE HEADER SCREEN CONTAINS THREE FIELDS USED TO POSITION     *                                00/00/00
0031.00       F* THE CIGARETTE PO SUBFILE.  THEY ARE VENDOR, ARRIVAL DATE     *                                00/00/00
0032.00       F* AND PO NUMBER.  THE HEADER SCREEN ALSO CONTAINS FIVE FILTER  *                                00/00/00
0033.00       F* FIELDS USED TO INCLUDE AND/OR EXCLUDE PO RECORDS.            *                                00/00/00
0034.00       F*                                                              *                                00/00/00
0035.00       F* IN THE SUBFILE, PRINT DATE IS THE DATE THE LABELS WERE       *                                00/00/00
0036.00       F* PRINTED USING THIS OPTION.  FULL DIST INDICATES WHETHER OR   *                                00/00/00
0037.00       F* NOT ALL ITEMS FOR THE PO HAVE BEEN FULLY DISTRIBUTED; IF AT  *                                00/00/00
0038.00       F* LEAST ONE ITEM HASN'T, "N" IS DISPLAYED.  RECV INDICATES     *                                00/00/00
0039.00       F* WHETHER OR NOT THE PO HAS BEEN RECEIVED AT THE DEPOT; IF AT  *                                00/00/00
0040.00       F* LEAST ONE ITEM HAS ANY QTY, "Y" IS DISPLAYED.  LIC INDICATES *                                00/00/00
0041.00       F* WHETHER OR NOT AT LEAST ONE LABEL FOR THE PO HAS MADE IT     *                                00/00/00
0042.00       F* ONTO A LICENSE; IF AT LEAST ONE HAS, "Y" IS DISPLAYED.       *                                00/00/00
0043.00       F*                                                              *                                00/00/00
0044.00       F* FILTER FIELDS CONFORM TO THE PREVIOUSLY DESCRIBED SUBFILE    *                                00/00/00
0045.00       F* FIELDS; IF LICENSE NUMBER IS KEYED, PO'S HAVING AT LEAST     *                                00/00/00
0046.00       F* ONE LABEL RECORD ON THAT LICENSE ARE DISPLAYED.              *                                00/00/00
0047.00       F*                                                              *                                00/00/00
0048.00       F* "P" IS KEYED IN THE SUBFILE TO GENERATE LABELS FOR THE ORDER *                                00/00/00
0049.00       F*  QUANTITY OF EACH ITEM IN THE PO. IT IS NOT ALLOWED IF AT    *                                00/00/00
0050.00       F*  LEAST ONE LABEL HAS BEEN PRINTED FOR THE PO, IF FULL DISTO  *                                00/00/00
0051.00       F*  DOESN'T EXIST FOR THE PO OR IF THE PO HAS BEEN RECEIVED.    *                                00/00/00
0052.00       F*                                                              *                                00/00/00
0053.00       F* "C" IS KEYED IN THE SUBFILE TO CANCEL THE LABEL PRINT, IN    *                                00/00/00
0054.00       F*  WHICH CASE LABELS ARE FLAGGED WITH STATUS OF "D".  IT IS    *                                00/00/00
0055.00       F*  NOT ALLOWED IF THE PO HAS BEEN RECEIVED OR IF AT LEAST ONE  *                                00/00/00
0056.00       F*  LABEL HAS BEEN PLACED ON A LICENSE.  THE SUBFILE PO IS DISP *                                00/00/00
0057.00       F*  IN RI IF LABELS HAVE BEEN CANCELED AT LEAST ONCE. THE       *                                00/00/00
0058.00       F*  FOLLOWING TWO SITUATIONS INDICATE THAT LABELS HAVE BEEN     *                                00/00/00
0059.00       F*  PRINTED AT LEAST ONCE (RI S01 PONO):                         *                               00/00/00
0060.00       F*                                                              *                                00/00/00
0061.00       F*  1.  ALL LABELS ARE "D"ELETED.                               *                                00/00/00
0062.00       F*  2.  IF ALL LABELS AREN'T "D"ELETED, LBFLG2="Y".             *                                00/00/00
0063.00       F*                                                              *                                00/00/00
0064.00       F*                                                              *                                00/00/00
0065.00       F* FOR EACH CIGARETTE PO, ALL QUANTITY MUST BE PROCESSED THRU   *                                00/00/00
0066.00       F* THIS LABEL PROCESS OR THROUGH SORT INR512.  IF AT LEAST ONE  *                                00/00/00
0067.00       F* UNIT FOR A PO IS PROCESSED THROUGH ONE PROCESS, EDITS IN THE *                                00/00/00
0068.00       F* OTHER PROCESS SHOULD PREVENT PROCESSING ANY QTY THROUGH THAT *                                00/00/00
0069.00       F* PROCESS AS WELL.                                             *                                00/00/00
0070.00       F*                                                              *                                00/00/00
0071.00       F****************************************************************                                00/00/00
0072.00       F*  REVISIONS:                                                  *                                00/00/00
0073.00       F*     DATE       PGMR          DESCRIPTION                     *                                00/00/00
0074.00       F*   --------   --------  ------------------------------------- *                                00/00/00
0075.00       F*                                                               *                               00/00/00
0076.00       F*                                                               *                               00/00/00
0077.00       F*   08/26/97   Tom Dick  Year 2000 and Fiscal Year Changes.     *                               00/00/00
0078.00       F*                        Replaced DATE with UTR100 for date     *                               00/00/00
0079.00       F*                        validation.                            *                               00/00/00
0080.00        *                                                                                               00/00/00
0081.00        *    3/01/99  WIESLAW  REMOVED CHECK FOR OLD CIGARETTE TYPE                                     00/00/00
0082.00        *                      PMFLG7.                                                                  00/00/00
0083.00       F*                                                              *                                00/00/00
0084.00       F*   05/08/00  MIKEV      ALTERED OUTPUT SPECS TO ACCOMODATE    *                                00/00/00
0085.00       F*                        NEW HIGH SPEED LABEL PRINTER          *                                00/00/00
0086.00       F*                                                              *                                00/00/00
0087.00       F*   06/06/03  UST       MODIFIED TO POPULATE THE NEW           *                                03/06/06
0088.00       F*                       WAREHOUSE FIELDS LBAWH5,LBWHS5         *                                03/06/06
0089.00       F*                       OF FILE INCGLBP.                       *                                03/06/06
0090.00       F*                                                              *                                03/06/06
0091.00       F*   08/25/03  UST       Replaced LDA data structure with       *                                03/08/25
0092.00       F*                       procedures GetJobLocn and GetJobWOutq. *                                03/08/25
0093.00       F*                                                              *                                04/09/04
0094.00       F*   09/04/04  UST       Modified for Warehouse Field Expansion.*                                04/09/04
0095.00       F*                                                              *                                04/09/04
0096.00       F*   04/13/05  M JONES   Labels changes associated with         *                                05/04/13
0097.00       F*                       expansion work above (to be installed  *                                05/04/13
0098.00       F*                       at the same time). Additional label    *                                05/04/13
0099.00       F*                       changes to simplify label testing.     *                                05/04/13
0100.00       F*                                                              *                                09/05/27
0101.00       F*   05/26/09  MMBODJI   Changed F1 exit to F3 exit             *                                09/05/27
0102.00       F*                                                              *                                10/01/25
0103.00       F*   01/25/10  JMILES    Change from GetJobWOutq to call INR2427*                                10/01/25
0104.00        //     Date     Programmer  Worklist #  Worklist / Task Description                             10/12/20
0105.00        //  ----------  ----------  ----------  ----------------------------------                      10/12/20
0106.00        //  12/02/2010   CBENDER    INMO00DS0G  Cleanup - various groups                                10/12/20
0107.00        // - Removed use of INIDSCP from program.                                                       10/12/20
0108.00        // - Replaced Chaing to INIDSCP for item description to call to service                         10/12/20
0109.00        //   program INS003 to get the item description                                                 10/12/20
0110.00        //                                                                                              10/12/20
0111.00       F*   2012-08-22 vmardiy   resized P1PONO from 15.5 to 17.5 to   *                                12/08/22
0112.00       F*                        match the incoming parm of INR1044.   *                                12/08/22
0113.00       F*                                                              *                                12/08/22
0114.00       F*                                                              *                                12/08/22
0115.00       F*   2024-05-16  LMANOJ    MODP007814  Datamax to ZPL Conversion*                                24/05/16
0116.00       F*                                     Project                                                   24/05/16
0117.00       F*                                     This program is a clone of*                               24/05/16
0118.00       F*                                     INR1031. Any changes done*                                24/05/16
0119.00       F*                                     to this program should be*                                24/05/16
0120.00       F*                                     included in INR1031.     *                                24/05/16
0121.00       F*                                     This program is called   *                                24/05/16
0122.00       F*                                     from a newly added wrapper*                               24/05/16
0123.00       F*                                     program INR1031W.        *                                24/05/16
0124.00       F*                                     CPI option will invoke   *                                24/05/16
0125.00       F*                                     INR1031W which will call *                                24/05/16
0126.00       F*                                     INR1031 if the location is*                               24/05/16
0127.00       F*                                     rolled-out to Datamax    *                                24/05/16
0128.00       F*                                     Printers else it will call*                               24/05/16
0129.00       F*                                     INR1031Z for the location *                               24/05/16
0130.00       F*                                     is rolled-out to ZPL     *                                24/05/16
0131.00       F*                                     printers.                *                                24/05/16
0132.00       F*                                     Also modified the program*                                24/05/16
0133.00       F*                                     to call INR1044W, a new wr*                               24/05/16
0134.00       F*                                     apper program, instead of*                                24/05/16
0135.00       F*                                     INR1044. Wrapper will call*                               24/05/16
0136.00       F*                                     INR1044 for locations with                                24/05/16
0137.00       F*                                     Datamax printers & INR1044Z*                              24/05/16
0138.00       F*                                     for locations with ZPL    *                               24/05/16
0139.00       F*                                     printers.                 *                               24/05/16
0140.00       F*                                                                                               24/05/16
0141.00       F* 2025-04-03  LMANOJ    MODP007814  Datamax to ZPL Conversion   *                               25/04/03
0142.00       F*                                   Made changes to retain the  *                               25/04/03
0143.00       F*                                   preceeding '0' while        *                               25/04/03
0144.00       F*                                   printing the barcode.       *                               25/04/03
0145.00       F*                                                               *                               25/12/22
0146.00       F* 2025-12-22  UST                   Modified the program to call*                               25/12/22
0147.00       F*                                   INR1044Z instead of         *                               25/12/22
0148.00       F*                                   INR1044W. Rearranged the    *                               25/12/22
0149.00       F*                                   INR1044Z calling parameters *                               25/12/22
0150.00       F*                                   accordingly.                *                               25/12/22
0150.10       F* 2026-10-21  AGENT                 SEQ missing on printed tag. *                               26/10/21
0150.20       F*                                   printZebraText at Y=1415    *                               26/10/21
0150.30       F*                                   sits on the barcode, so     *                               26/10/21
0150.40       F*                                   the sequence never shows.   *                               26/10/21
0150.50       F*                                   Typeset it on the SEQ       *                               26/10/21
0150.60       F*                                   baseline and keep the       *                               26/10/21
0150.70       F*                                   leading zeros (edit X).     *                               26/10/21
0150.80       F*                                                               *                               26/10/21
0151.00       F****************************************************************                                24/05/16
0152.00       F*                       INDICATOR SUMMARY                      *                                00/00/00
0153.00       F*  IN03 = EXIT PGM                                             *                                09/05/27
0154.00       F*  IN05 = REFRESH                                              *                                00/00/00
0155.00       F*  IN13 = RESTART CMD KEY                                      *                                00/00/00
0156.00       F*  IN25 = SFLNXTCHG (S01)                                      *                                00/00/00
0157.00       F*  IN26 = ROLLUP                                               *                                00/00/00
0158.00       F*  IN27 = SFLDSP/SFLDSPCTL SFL1                                *                                00/00/00
0159.00       F*  IN28 = SFLDSP/SFLDSPCTL SFL2                                *                                00/00/00
0160.00       F*  IN29 = SFLEND                                               *                                00/00/00
0161.00       F*  IN32 = ERROR: SEARCH BY DEPT/VEND/SUFF, PO#, DATE OR LIC#   *                                00/00/00
0162.00       F*  IN36 = ERROR: POSITION DATE (ARDT) IS INVALID               *                                00/00/00
0163.00       F*  IN37 = ERROR: FILTER DATE IS INVALID                        *                                00/00/00
0164.00       F*  IN40 = S01 'X': ERROR - NO LABELS EXIST                     *                                00/00/00
0165.00       F*  IN41 = S01 'P' OR 'C': ERROR - PO HAS BEEN RECEIVED         *                                00/00/00
0166.00       F*  IN42 = S01 'P': ERROR - FULL DISTR DOESN'T EXIST FOR PO     *                                00/00/00
0167.00       F*  IN43 = S01 'X': ERROR - LABELS ALREADY PRINTED              *                                00/00/00
0168.00       F*  IN44 = S01 'P': ERROR - INVALID PRINTER IN C01              *                                00/00/00
0169.00       F*  IN45 = S01 'P': DISPLAY MESSAGE 'PRINT COMPLETE'            *                                00/00/00
0170.00       F*  IN46 = S01 'C': ERROR - LABELS HAVEN'T BEEN PRINTED YET     *                                00/00/00
0171.00       F*  IN48 = S01 'C': ERROR - LABEL ON A LICENSE                  *                                00/00/00
0172.00       F*  IN49 = S01 'C': DISPLAY MESSAGE 'PRINT REQUEST CANCELLED'   *                                00/00/00
0173.00       F*  IN50 = CHANGE INDICATIOR C01                                *                                00/00/00
0174.00       F*  IN51 = S01 HI-LITE PO# IF LABELS CANCELLED                  *                                00/00/00
0175.00       F*  IN60 = USED IN ACCESS TO SFL RECORDS                        *                                00/00/00
0176.00       F*  IN61 = SETLL INPMSTR30/INPMSTR32/INPMSTR35                  *                                04/09/04
0177.00       F*  IN62 = ERROR: NO PO  RECS FOUND FOR VEND/SUFF SEARCH FIELDS *                                00/00/00
0178.00       F*  IN63 = ERROR: NO PO  RECS FOUND FOR PONO SEARCH FIELDS      *                                00/00/00
0179.00       F*  IN64 = ERROR: NO PO  RECS FOUND FOR ARDT SEARCH FIELDS      *                                00/00/00
0180.00       F*  IN68 = READE INPMSTR30/INPMSTR32/INPMSTR35                  *                                04/09/04
0181.00       F*  IN70 = RECORD NOT FOUND IN INWCTL30 FILE                    *                                04/09/04
0182.00       F*  IN71 = INCGLBP,INCGLB31,INCGLB32,INPDTR30                   *                                04/09/04
0183.00       F*  IN72 = RECORD NOT FOUND IN INVMST30,INVMST07                *                                04/09/04
0184.00       F*  IN74 = USED TO CHAIN TO INPMST30 WHEN 'P' LABEL PRINT       *                                04/09/04
0185.00       F*  IN80 = RECORD LOCK INDICATOR                                *                                00/00/00
0186.00       F*  IN90 = PRINTER FILE OVERFLOW                                *                                00/00/00
0187.00       F*  IN91 = READE INPDTR30                                       *                                04/09/04
0188.00       F*  IN92 = READE INPDSH39                                       *                                04/09/04
0189.00       F*  IN96 = INPITM30                                             *                                10/12/20
0190.00       F****************************************************************                                00/00/00
0191.00       FINPMST30  IF   E           K DISK    USROPN                                                     04/09/04
0192.00       FINPMST32  IF   E           K DISK    USROPN                                                     04/09/04
0193.00       F                                     RENAME(INPMSTR:INPMSTR32)                                  04/09/04
0194.00       FINPMST35  IF   E           K DISK    USROPN                                                     04/09/04
0195.00       F                                     RENAME(INPMSTR:INPMSTR35)                                  04/09/04
0196.00       FINVMST30  IF   E           K DISK    USROPN                                                     04/09/04
0197.00       FINVMST07  IF   E           K DISK    USROPN                                                     00/00/00
0198.00       F                                     RENAME(INVMSTR:INVMST7)                                    00/00/00
0199.00       FINWCTL30  IF   E           K DISK    USROPN                                                     04/09/01
0200.00       F*                                                                                               00/00/00
0201.00       FINCGLBP   O  A E             DISK    USROPN                                                     00/00/00
0202.00       FINCGLB31  IF   E           K DISK    USROPN                                                     04/09/04
0203.00       F                                     RENAME(INCGLBR:INCGLBR31)                                  04/09/04
0204.00       FINCGLB32  UF   E           K DISK    USROPN                                                     04/09/04
0205.00       F                                     RENAME(INCGLBR:INCGLBR32)                                  04/09/04
0206.00       FINPDTR30  IF   E           K DISK    USROPN                                                     04/09/04
0207.00       FINPDTR36  IF   E           K DISK    USROPN                                                     04/09/04
0208.00       F                                     RENAME(INPDTRR:INPDTRR36)                                  04/09/04
0209.00       FINPDSH39  IF   E           K DISK    USROPN                                                     04/09/04
0210.00       FINPITM30  IF   E           K DISK    USROPN                                                     04/09/04
0211.00       FIND1031   CF   E             WORKSTN USROPN                                                     00/00/00
0212.00       F                                     SFILE(S01:RR1)                                             00/00/00
0213.00                                                                                                        10/12/20
0214.00        // =======================================================================                      10/12/20
0215.00        // - Prototype Definitions - External Procedures from Service Programs                          10/12/20
0216.00        // =======================================================================                      10/12/20
0217.00        /copy *libl/QRPGLESRC,UTRCPY004                                                                 10/12/20
0218.00                                                                                                        10/12/20
0219.00        /define typeDefinitions_INS003                                                                  10/12/20
0220.00        /define getitemDescription1_INS003                                                              10/12/20
0221.00        /copy *libl/QRPGLESRC,INS003PR                                                                  10/12/20
0222.00        *                                                                                               03/08/25
0223.00        * External Procedures                                                                           03/08/25
0224.00        /Define GetJobLocn_AIS001                                                                       03/08/25
0225.00        /COPY *libl/QRPGLESRC,AIS001PR                                                                  03/08/25
0226.00                                                                                                        24/05/16
0227.00        /define typeDefinitions_UTS008                                                                  24/05/16
0228.00        /define calculatePrintQuantity_UTS008                                                           24/05/16
0229.00        /define closeZebraPrinterFile_UTS008                                                            24/05/16
0230.00        /define endZebraLabel_UTS008                                                                    24/05/16
0231.00        /define openZebraPrinterFile_UTS008                                                             24/05/16
0232.00        /define setZebraBarCodeValidation_UTS008                                                        24/05/16
0233.00        /define printZebraBarCodeC128_UTS008                                                            24/05/16
0234.00        /define printZebraGraphicBox_UTS008                                                             24/05/16
0235.00        /define printZebraText_UTS008                                                                   24/05/16
0236.00        /define printZebraTextTypeset_UTS008                                                            24/05/16
0237.00        /define printZebraTextBlock_UTS008                                                              24/05/16
0238.00        /define printZebraTextReverse_UTS008                                                            24/05/16
0239.00        /define setZebraBarCodeDefaults_UTS008                                                          24/05/16
0240.00        /define setZebraDefaultFont_UTS008                                                              24/05/16
0241.00        /define setZebraPrintQuantity_UTS008                                                            24/05/16
0242.00        /define setZebraUnitsOfMeasure_UTS008                                                           24/05/16
0243.00        /define setZebraFieldOrientation_UTS008                                                         24/05/16
0244.00        /define startZebraLabel_UTS008                                                                  24/05/16
0245.00        /copy *libl/QRPGLESRC,UTS008PR                                                                  24/05/16
0246.00                                                                                                        24/05/16
0247.00        *                                                                                               00/00/00
0248.00       D AR              S             62    DIM(9999)                                                  04/09/04
0249.00       D A1              S             62    DIM(9999)                                                  04/09/04
0250.00       D*                                                                                               03/08/25
0251.00       D C1WHSE          S                   LIKE(WCWHS5)                                               04/09/04
0252.00       D WKZERO          S                   LIKE(PDWHS5)                                               04/09/04
0253.00       D PRWHS1          S                   LIKE(LBWHS5)                                               04/09/04
0254.00       D PRWHS2          S                   LIKE(LBWHS5)                                               04/09/04
0255.00                                                                                                        04/09/04
0256.00        *  Declaration to be deleted after Phase IV of Field Expansion.                                 04/09/01
0257.00       D LBAWHS          S              3  0                                                            04/09/04
0258.00       D LBWHSE          S              3  0                                                            04/09/04
0259.00       D*                                                                                               00/00/00
0260.00       D* TIME OF DAY DATA STRUCTURE                                                                    00/00/00
0261.00       D                 DS                                                                             00/00/00
0262.00       D  TIMDAT                 1     12  0                                                            00/00/00
0263.00       D  TTIM                   1      6  0                                                            00/00/00
0264.00       D  TDAT                   7     12  0                                                            00/00/00
0265.00       D*                                                                                               00/00/00
0266.00       D* Date Conversion                                                                               00/00/00
0267.00       D*                                                                                               00/00/00
0268.00       D                 DS                                                                             00/00/00
0269.00       D  CVTYMD                 1      7  0 INZ                                                        00/00/00
0270.00       D  CVTCC                  1      1                                                               00/00/00
0271.00       D  CVTYY1                 2      3                                                               00/00/00
0272.00       D  CVTMM                  4      5                                                               00/00/00
0273.00       D  CVTDD                  6      7                                                               00/00/00
0274.00       D  CVTYY2                 8      9                                                               00/00/00
0275.00       D  CVTMDY                 4      9  0 INZ                                                        00/00/00
0276.00       D*                                                                                               00/00/00
0277.00       D                 DS                                                                             00/00/00
0278.00       D  C1VEND                 1      5  0                                                            00/00/00
0279.00       D  C1SUFF                 6      7  0                                                            00/00/00
0280.00       D  C1PONO                 8     19  0                                                            04/09/04
0281.00       D  C1DATE                20     25  0                                                            04/09/04
0282.00       D  C1PRDT                26     31  0                                                            04/09/04
0283.00       D  C1LINO                32     38  0                                                            04/09/04
0284.00       D  C1RECV                39     39                                                               04/09/04
0285.00       D  C1LICN                40     40                                                               04/09/04
0286.00       D  C1FULL                41     41                                                               04/09/04
0287.00       D  SCNN01                 1     38                                                               04/09/04
0288.00       D  SCNA01                39     41                                                               04/09/04
0289.00       D  SCNC01                 1     41                                                               04/09/04
0290.00       D*                                                                                               00/00/00
0291.00       D                 DS                                                                             00/00/00
0292.00       D  H1VEND                 1      5  0                                                            00/00/00
0293.00       D  H1SUFF                 6      7  0                                                            00/00/00
0294.00       D  H1PONO                 8     19  0                                                            04/09/04
0295.00       D  H1DATE                20     25  0                                                            04/09/04
0296.00       D  H1PRDT                26     31  0                                                            04/09/04
0297.00       D  H1LINO                32     38  0                                                            04/09/04
0298.00       D  H1RECV                39     39                                                               04/09/04
0299.00       D  H1LICN                40     40                                                               04/09/04
0300.00       D  H1FULL                41     41                                                               04/09/04
0301.00       D  HLDN01                 1     38                                                               04/09/04
0302.00       D  HLDA01                39     41                                                               04/09/04
0303.00       D  HLDC01                 1     41                                                               04/09/04
0304.00       D*                                                                                               00/00/00
0305.00       D                 DS                                                                             00/00/00
0306.00       D  DSWHSE                 1      5                                                               04/09/04
0307.00       D  DSSEQ#                 6     10                                                               04/09/04
0308.00       D  DSBUPC                11     17                                                               04/09/04
0309.00       D  DSITEM                18     24                                                               04/09/04
0310.00       D  DSQSHP                25     31                                                               04/09/04
0311.00       D  DSDESC                32     56                                                               04/09/04
0312.00       D  DSPART                57     57                                                               04/09/04
0313.00       D  DSASEQ                58     62                                                               04/09/04
0314.00       D  DSDATA                 1     62                                                               04/09/04
0315.00       D*                                                                                               00/00/00
0316.00       D                 DS                                                                             00/00/00
0317.00       D  S1PONO                 1     12  0                                                            04/09/04
0318.00       D  W1WHSE                 1      5  0                                                            04/09/04
0319.00       D  W1PONO                 6     12  0                                                            04/09/04
0320.00       D                 DS                                                                             00/00/00
0321.00       D  C2PONO                 1     12  0                                                            04/09/04
0322.00       D  W2WHSE                 1      5  0                                                            04/09/04
0323.00       D  W2PONO                 6     12  0                                                            04/09/04
0324.00       D*                                                                                               00/00/00
0325.00       D                 DS                                                                             00/00/00
0326.00       D  LBAWH5                 1      5  0                                                            04/09/04
0327.00       D  LBPONO                 6     12  0                                                            04/09/04
0328.00       D  PRPONO                 1     12                                                               04/09/04
0329.00       D*                                                                                               00/00/00
0330.00       D                 DS                                                                             00/00/00
0331.00       D  WKPON1                 1      7  0                                                            00/00/00
0332.00       D  WKSEQ1                 8     12  0                                                            00/00/00
0333.00       D  PRBRC1                 1     12  0                                                            00/00/00
0334.00       D*                                                                                               00/00/00
0335.00       D                 DS                                                                             00/00/00
0336.00       D  WKPON2                 1      7  0                                                            00/00/00
0337.00       D  WKSEQ2                 8     12  0                                                            00/00/00
0338.00       D  PRBRC2                 1     12  0                                                            00/00/00
0339.00       D*                                                                                               00/00/00
0340.00       D                 DS                                                                             00/00/00
0341.00       D* CMD1                   1     38                                                               24/05/16
0342.00       D*                                    DIM(1) CTDATA PERRCD(1)              OVRPRTF CMD           24/05/16
0343.00       D  WKOUTQ                28     37                                                               00/00/00
0344.00       D*                                                                                               00/00/00
0345.00       D                 DS                                                                             00/00/00
0346.00       D  CMD2                   1     38                                                               00/00/00
0347.00       D                                     DIM(1) CTDATA PERRCD(1)              CHKOBJ  CMD           00/00/00
0348.00       D  W2OUTQ                12     21                                                               00/00/00
0349.00        * ----------------------------------------------------------------------*                       24/05/16
0350.00        * - Internal Procedures                                                 *                       24/05/16
0351.00        * ----------------------------------------------------------------------*                       24/05/16
0352.00                                                                                                        24/05/16
0353.00        * Printer Procedures for each label                                                             24/05/16
0354.00       D printlbl30      PR                                                                             24/05/16
0355.00       D printlbl60      PR                                                                             24/05/16
0356.00                                                                                                        24/05/16
0357.00       C*                                                                                               00/00/00
0358.00       C     LBKEY1        KLIST                                                                        00/00/00
0359.00       C                   KFLD                    C1WHSE                                               00/00/00
0360.00       C                   KFLD                    PMPONO                                               00/00/00
0361.00       C                   KFLD                    WKSTAT                                               00/00/00
0362.00       C*                                                                                               00/00/00
0363.00       C     LBKEY2        KLIST                                                                        00/00/00
0364.00       C                   KFLD                    C1WHSE                                               00/00/00
0365.00       C                   KFLD                    C1LINO                                               00/00/00
0366.00       C                   KFLD                    PMPONO                                               00/00/00
0367.00       C*                                                                                               00/00/00
0368.00       C     LBKEY3        KLIST                                                                        00/00/00
0369.00       C                   KFLD                    C1WHSE                                               00/00/00
0370.00       C                   KFLD                    W1PONO                                               00/00/00
0371.00       C                   KFLD                    WKSTAT                                               00/00/00
0372.00       C*                                                                                               00/00/00
0373.00       C     PDKEY         KLIST                                                                        00/00/00
0374.00       C                   KFLD                    WKZERO                                               00/00/00
0375.00       C                   KFLD                    C1WHSE                                               00/00/00
0376.00       C                   KFLD                    WKFPT                                                00/00/00
0377.00       C                   KFLD                    PMPONO                                               00/00/00
0378.00       C*                                                                                               00/00/00
0379.00       C     PDKEY1        KLIST                                                                        00/00/00
0380.00       C                   KFLD                    WKFPT                                                00/00/00
0381.00       C                   KFLD                    PMWHS5                                               04/09/04
0382.00       C                   KFLD                    PMPONO                                               00/00/00
0383.00       C*                                                                                               00/00/00
0384.00       C     PIKEY         KLIST                                                                        00/00/00
0385.00       C                   KFLD                    PMWHS5                                               04/09/04
0386.00       C                   KFLD                    PMDEPT                                               00/00/00
0387.00       C                   KFLD                    PMVEND                                               00/00/00
0388.00       C                   KFLD                    PMSUFF                                               00/00/00
0389.00       C                   KFLD                    PMPONO                                               00/00/00
0390.00       C                   KFLD                    PDITEM                                               00/00/00
0391.00       C*                                                                                               00/00/00
0392.00       C     PMKEY         KLIST                                                                        00/00/00
0393.00       C                   KFLD                    C1WHSE                                               00/00/00
0394.00       C                   KFLD                    C1DEPT                                               00/00/00
0395.00       C                   KFLD                    C1VEND                                               00/00/00
0396.00       C                   KFLD                    C1SUFF                                               00/00/00
0397.00       C*                                                                                               00/00/00
0398.00       C     PMKEY1        KLIST                                                                        00/00/00
0399.00       C                   KFLD                    C1WHSE                                               00/00/00
0400.00       C                   KFLD                    W2PONO                                               00/00/00
0401.00       C*                                                                                               00/00/00
0402.00       C     PMKEY2        KLIST                                                                        00/00/00
0403.00       C                   KFLD                    C1WHSE                                               00/00/00
0404.00       C                   KFLD                    C1DEPT                                               00/00/00
0405.00       C                   KFLD                    WKDATE            7 0                                00/00/00
0406.00       C*                                                                                               00/00/00
0407.00       C     PMKEY3        KLIST                                                                        00/00/00
0408.00       C                   KFLD                    C1WHSE                                               00/00/00
0409.00       C                   KFLD                    C1DEPT                                               00/00/00
0410.00       C                   KFLD                    S1VEND                                               00/00/00
0411.00       C                   KFLD                    S1SUFF                                               00/00/00
0412.00       C                   KFLD                    W1PONO                                               00/00/00
0413.00       C*                                                                                               00/00/00
0414.00       C     PMKEY4        KLIST                                                                        00/00/00
0415.00       C                   KFLD                    C1WHSE                                               00/00/00
0416.00       C                   KFLD                    WKDEPT                                               00/00/00
0417.00       C*                                                                                               00/00/00
0418.00       C     PMKEY5        KLIST                                                                        00/00/00
0419.00       C                   KFLD                    C1WHSE                                               00/00/00
0420.00       C                   KFLD                    WKDEPT                                               00/00/00
0421.00       C                   KFLD                    SVVEND                                               00/00/00
0422.00       C                   KFLD                    SVSUFF                                               00/00/00
0423.00       C                   KFLD                    SVPONO                                               00/00/00
0424.00       C*                                                                                               00/00/00
0425.00       C     PMKEY6        KLIST                                                                        00/00/00
0426.00       C                   KFLD                    C1WHSE                                               00/00/00
0427.00       C                   KFLD                    SVPONO                                               00/00/00
0428.00       C*                                                                                               00/00/00
0429.00       C     PMKEY7        KLIST                                                                        00/00/00
0430.00       C                   KFLD                    C1WHSE                                               00/00/00
0431.00       C                   KFLD                    WKDEPT                                               00/00/00
0432.00       C                   KFLD                    SVARDT                                               00/00/00
0433.00       C                   KFLD                    SVVEND                                               00/00/00
0434.00       C                   KFLD                    SVSUFF                                               00/00/00
0435.00       C                   KFLD                    SVPONO                                               00/00/00
0436.00       C*                                                                                               00/00/00
0437.00       C     PSKEY         KLIST                                                                        00/00/00
0438.00       C                   KFLD                    WKFPT                                                00/00/00
0439.00       C                   KFLD                    PDAWH5                                               04/09/04
0440.00       C                   KFLD                    PDPONO                                               00/00/00
0441.00       C                   KFLD                    PDITEM                                               00/00/00
0442.00       C                   KFLD                    WKDSDT                                               00/00/00
0443.00       C*                                                                                               00/00/00
0444.00       C     VMKEY         KLIST                                                                        00/00/00
0445.00       C                   KFLD                    WKDEPT                                               00/00/00
0446.00       C                   KFLD                    WKVEND                                               00/00/00
0447.00       C                   KFLD                    WKSUFF                                               00/00/00
0448.00       C*                                                                                               00/00/00
0449.00       C     VMKEY1        KLIST                                                                        00/00/00
0450.00       C                   KFLD                    PMWHS5                                               04/09/04
0451.00       C                   KFLD                    PMDEPT                                               00/00/00
0452.00       C                   KFLD                    PMVEND                                               00/00/00
0453.00       C                   KFLD                    PMSUFF                                               00/00/00
0454.00       C*                                                                                               00/00/00
0455.00       C     VMKEY2        KLIST                                                                        00/00/00
0456.00       C                   KFLD                    C1WHSE                                               00/00/00
0457.00       C                   KFLD                    WKDEPT                                               00/00/00
0458.00       C                   KFLD                    WKVEND                                               00/00/00
0459.00       C                   KFLD                    WKSUFF                                               00/00/00
0460.00       C*                                                                                               00/00/00
0461.00       C*                                                                                               00/00/00
0462.00       C     *LIKE         DEFINE    PSDSDT        WKDSDT                                               00/00/00
0463.00       C     *LIKE         DEFINE    PSQORD        TOSHIP                                               00/00/00
0464.00       C     *LIKE         DEFINE    PDQSHP        WKQSHP                                               00/00/00
0465.00       C     *LIKE         DEFINE    PDVBUQ        WKSELU                                               00/00/00
0466.00       C     *LIKE         DEFINE    VMNAME        PRNAME                                               00/00/00
0467.00       C     *LIKE         DEFINE    LBDESC        PRDESC                                               00/00/00
0468.00       C     *LIKE         DEFINE    C1PNTR        SVPNTR                                               00/00/00
0469.00       C     *LIKE         DEFINE    C1PNTR        WKPNTR                                               10/01/25
0470.00       C     *LIKE         DEFINE    PMVEND        SVVEND                                               00/00/00
0471.00       C     *LIKE         DEFINE    PMSUFF        SVSUFF                                               00/00/00
0472.00       C     *LIKE         DEFINE    PMPONO        SVPONO                                               00/00/00
0473.00       C     *LIKE         DEFINE    PMARDT        SVARDT                                               00/00/00
0474.00       C     *LIKE         DEFINE    C1OPTN        SVOPTN                                               00/00/00
0475.00       C     *LIKE         DEFINE    C1DEPT        WKDEPT                                               00/00/00
0476.00       C     *LIKE         DEFINE    C1VEND        WKVEND                                               00/00/00
0477.00       C     *LIKE         DEFINE    C1SUFF        WKSUFF                                               00/00/00
0478.00       C     *LIKE         DEFINE    C1OPTN        P1OPTN                                               00/00/00
0479.00       C     *LIKE         DEFINE    WCCMPY        WKCMPY                                               00/00/00
0480.00       C     *LIKE         DEFINE    H1CANC        WKCANC                                               00/00/00
0481.00       C*                                                                                               00/00/00
0482.00       C*                                                                                               00/00/00
0483.00        /EJECT                                                                                          00/00/00
0484.00       C****************************************************************                                00/00/00
0485.00       C*            FIRST-TIME INITIALIZATION SECTION                 *                                00/00/00
0486.00       C****************************************************************                                00/00/00
0487.00       C*                                                                                               00/00/00
0488.00        *                                                                                               00/00/00
0489.00       C     *ENTRY        PLIST                                                                        00/00/00
0490.00       C                   PARM                    C1OPTN                                               00/00/00
0491.00       C                   PARM      *IN03         #IN03             1                                  09/05/27
0492.00        *                                                                                               00/00/00
0493.00       C*                                                                                               00/00/00
0494.00       C                   EXSR      FINIT                                                              00/00/00
0495.00       C*                                                                                               00/00/00
0496.00       C                   EXSR      GETTIM                                                             00/00/00
0497.00       C*                                                                                               00/00/00
0498.00       C*                                                                                               00/00/00
0499.00       C* Get Job Info.                                                                                 03/08/25
0500.00       C                   EVAL      C1WHSE = GetJobLocn                                                03/08/25
0501.00       C*                                                                                               00/00/00
0502.00       C     C1WHSE        CHAIN     INWCTLR                            70                              00/00/00
0503.00       C     *IN70         IFEQ      *OFF                                                               00/00/00
0504.00       C                   MOVE      WCCMPY        WKCMPY                                               00/00/00
0505.00       C                   ELSE                                                                         00/00/00
0506.00       C                   MOVE      *BLANKS       WKCMPY                                               00/00/00
0507.00       C                   END                                                                          00/00/00
0508.00       C*                                                                                               00/00/00
0509.00       C*                                                                                               00/00/00
0510.00       C                   SETOFF                                       13                              00/00/00
0511.00       C                   MOVE      *ON           *IN29                                                00/00/00
0512.00       C                   MOVEA     '000'         *IN(26)                        SFLCLR                00/00/00
0513.00       C                   WRITE     C01                                                                00/00/00
0514.00       C                   WRITE     R01                                                                00/00/00
0515.00       C                   MOVE      'Y'           ERROR             1                                  00/00/00
0516.00       C*                                                                                               00/00/00
0517.00       C*                                                                                               00/00/00
0518.00       C*                                                                                               00/00/00
0519.00       C                   MOVE      *OFF          *IN27                                                00/00/00
0520.00       C                   MOVE      *ON           *IN28                                                00/00/00
0521.00       C                   EXFMT     C01                                                                00/00/00
0522.00       C*                                                                                               00/00/00
0523.00       C*                                                                                               00/00/00
0524.00       C                   MOVE      *BLANK        ERROR                                                00/00/00
0525.00       C*                                                                                               00/00/00
0526.00       C*                                                                                               00/00/00
0527.00        /EJECT                                                                                          00/00/00
0528.00       C****************************************************************                                00/00/00
0529.00       C*                  MAINLINE SECTION                            *                                00/00/00
0530.00       C****************************************************************                                00/00/00
0531.00       C*                                                                                               00/00/00
0532.00       C*                                                                                               00/00/00
0533.00       C*                                                                                               00/00/00
0534.00       C     *IN03         DOWEQ     '0'                                                                09/05/27
0535.00       C     C1OPTN        ANDEQ     'CPI'                                                              00/00/00
0536.00       C*                                                                                               00/00/00
0537.00       C                   EXSR      SFLC01                                                             00/00/00
0538.00       C*                                                                                               00/00/00
0539.00       C     *IN03         IFEQ      *OFF                                                               09/05/27
0540.00       C     C1OPTN        ANDEQ     'CPI'                                                              00/00/00
0541.00       C                   EXFMT     C01                                                                00/00/00
0542.00       C                   ENDIF                                                                        00/00/00
0543.00       C*                                                                                               00/00/00
0544.00       C                   ENDDO                                                  DOW                   00/00/00
0545.00       C*                                                                                               00/00/00
0546.00       C*********************************                                                               00/00/00
0547.00       C*  END PROGRAM W/OUT SETTING ON LR                                                              00/00/00
0548.00       C*********************************                                                               00/00/00
0549.00       C*                                                                                               00/00/00
0550.00       C                   CLOSE     IND1031                                                            00/00/00
0551.00       C*                                                                                               00/00/00
0552.00       C*                                                                                               00/00/00
0553.00       C                   RETURN                                                                       00/00/00
0554.00        /EJECT                                                                                          00/00/00
0555.00        ************************** SFLC01 *******************************                               00/00/00
0556.00        *   SUBROUTINE TO CONTROL PROCESSING OF CIGARETTE PO SUBFILE    *                               00/00/00
0557.00        ************************** SFLC01 *******************************                               00/00/00
0558.00       C*                                                                                               00/00/00
0559.00       C     SFLC01        BEGSR                                                                        00/00/00
0560.00       C*                                                                                               00/00/00
0561.00       C*                                                                                               00/00/00
0562.00       C     *IN13         IFEQ      *OFF                                                               00/00/00
0563.00       C*                                                                                               00/00/00
0564.00       C     RR1           IFEQ      0                                                                  00/00/00
0565.00       C                   SETOFF                                       27                              00/00/00
0566.00       C                   END                                                                          00/00/00
0567.00       C*                                                                                               00/00/00
0568.00       C     *IN05         IFEQ      *ON                                                                00/00/00
0569.00       C     FLGC01        ANDEQ     *ON                                                                00/00/00
0570.00       C                   MOVE      HLDC01        SCNC01                                               00/00/00
0571.00       C*                                                                                               00/00/00
0572.00       C     C1PONO        IFNE      0                                                                  00/00/00
0573.00       C                   MOVEL     C1WHSE        C1PONO                                               00/00/00
0574.00       C                   ENDIF                                                                        00/00/00
0575.00       C*                                                                                               00/00/00
0576.00       C                   ELSE                                                                         00/00/00
0577.00       C*                                                                                               00/00/00
0578.00       C*                                                                                               00/00/00
0579.00       C     SCNC01        IFNE      HLDC01                                                             00/00/00
0580.00       C*                                                                                               00/00/00
0581.00       C     SCNA01        IFEQ      *BLANKS                                                            00/00/00
0582.00       C     SCNN01        ANDEQ     *ZEROS                                                             00/00/00
0583.00       C                   MOVE      *OFF          *IN50                                                00/00/00
0584.00       C     FLGC01        IFEQ      *ON                                                                00/00/00
0585.00       C                   MOVE      HLDC01        SCNC01                                               00/00/00
0586.00       C*                                                                                               00/00/00
0587.00       C     C1PONO        IFNE      0                                                                  00/00/00
0588.00       C                   MOVEL     C1WHSE        C1PONO                                               00/00/00
0589.00       C                   ENDIF                                                                        00/00/00
0590.00       C*                                                                                               00/00/00
0591.00       C                   ELSE                                                                         00/00/00
0592.00       C                   MOVE      SCNC01        HLDC01                                               00/00/00
0593.00       C                   MOVE      *OFF          *IN32                                                00/00/00
0594.00       C                   MOVE      *OFF          *IN36                                                00/00/00
0595.00       C                   MOVE      *OFF          *IN37                                                00/00/00
0596.00       C                   MOVE      *OFF          *IN44                                                00/00/00
0597.00       C                   MOVE      *OFF          *IN62                                                00/00/00
0598.00       C                   MOVE      *OFF          *IN63                                                00/00/00
0599.00       C                   MOVE      *OFF          *IN64                                                00/00/00
0600.00       C                   ENDIF                                                                        00/00/00
0601.00       C                   ELSE                                                                         00/00/00
0602.00       C                   MOVE      SCNC01        HLDC01                                               00/00/00
0603.00       C                   ENDIF                                                                        00/00/00
0604.00       C*                                                                                               00/00/00
0605.00       C                   ELSE                                                                         00/00/00
0606.00       C                   MOVE      *OFF          *IN50                                                00/00/00
0607.00       C*                                                                                               00/00/00
0608.00       C                   ENDIF                                                                        00/00/00
0609.00       C*                                                                                               00/00/00
0610.00       C                   ENDIF                                                                        00/00/00
0611.00       C*                                                                                               00/00/00
0612.00       C*                                                                                               00/00/00
0613.00       C*                                                                                               00/00/00
0614.00       C                   SELECT                                                                       00/00/00
0615.00       C*                                                                                               00/00/00
0616.00       C*                                                                                               00/00/00
0617.00       C     *IN50         WHENEQ    *ON                                          CHANGE C01            00/00/00
0618.00       C     *IN05         OREQ      *ON                                          F5 REFRESH            00/00/00
0619.00       C     FLGC01        ANDEQ     *ON                                                                00/00/00
0620.00       C*                                                                                               00/00/00
0621.00       C                   MOVE      *OFF          *IN32                                                00/00/00
0622.00       C                   MOVE      *OFF          *IN40                                                00/00/00
0623.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0624.00       C                   MOVE      *OFF          *IN42                                                00/00/00
0625.00       C                   MOVE      *OFF          *IN43                                                00/00/00
0626.00       C                   MOVE      *OFF          *IN45                                                00/00/00
0627.00       C                   MOVE      *OFF          *IN46                                                00/00/00
0628.00       C                   MOVE      *OFF          *IN48                                                00/00/00
0629.00       C                   MOVE      *OFF          *IN49                                                00/00/00
0630.00       C                   MOVE      *OFF          *IN50                                                00/00/00
0631.00       C*                                                                                               00/00/00
0632.00       C                   MOVE      *BLANK        ERROR                                                00/00/00
0633.00       C*                                                                                               00/00/00
0634.00       C*                                                                                               00/00/00
0635.00       C                   MOVE      ' '           ERROR                                                00/00/00
0636.00       C                   EXSR      EDITH                                                              00/00/00
0637.00       C*                                                                                               00/00/00
0638.00       C     ERROR         IFEQ      ' '                                                                00/00/00
0639.00       C     *IN03         IFEQ      '0'                                                                09/05/27
0640.00       C     C1OPTN        ANDEQ     'CPI'                                                              00/00/00
0641.00       C*                                                                                               00/00/00
0642.00       C                   MOVE      *OFF          *IN27                                                00/00/00
0643.00       C                   MOVE      *ON           *IN28                                                00/00/00
0644.00       C                   WRITE     C01                                                                00/00/00
0645.00       C                   Z-ADD     0             SVRR1             3 0                                00/00/00
0646.00       C                   SETOFF                                       2947                            00/00/00
0647.00       C                   SETON                                        2728                            00/00/00
0648.00       C                   EXSR      LOAD1                                                              00/00/00
0649.00       C*                                                                                               00/00/00
0650.00       C     RR1           IFEQ      0                                                                  00/00/00
0651.00       C                   SELECT                                                                       00/00/00
0652.00       C     WKKEYS        WHENEQ    'DV'                                                               00/00/00
0653.00       C                   MOVE      *ON           *IN62                                                00/00/00
0654.00       C     WKKEYS        WHENEQ    'PO'                                                               00/00/00
0655.00       C                   MOVE      *ON           *IN63                                                00/00/00
0656.00       C     WKKEYS        WHENEQ    'DT'                                                               00/00/00
0657.00       C                   MOVE      *ON           *IN64                                                00/00/00
0658.00       C                   ENDSL                                                                        00/00/00
0659.00       C                   WRITE     R01                                                                00/00/00
0660.00       C                   MOVE      *OFF          *IN27                                                00/00/00
0661.00       C                   MOVE      *OFF          FLGC01                                               00/00/00
0662.00       C                   ELSE                                                                         00/00/00
0663.00       C                   MOVE      *ON           FLGC01            1                                  00/00/00
0664.00       C                   ENDIF                                                                        00/00/00
0665.00       C*                                                                                               00/00/00
0666.00       C*                                                                                               00/00/00
0667.00       C                   END                                                    *IN03=0               09/05/27
0668.00       C*                                                                                               00/00/00
0669.00       C                   ENDIF                                                                        00/00/00
0670.00       C*                                                                                               00/00/00
0671.00       C*                                                                                               00/00/00
0672.00       C     *IN26         WHENEQ    '1'                                          ROLLUP                00/00/00
0673.00       C                   EXSR      LOAD1                                                              00/00/00
0674.00       C*                                                                                               00/00/00
0675.00       C*                                                                                               00/00/00
0676.00       C                   OTHER                                                                        00/00/00
0677.00       C*                                                                                               00/00/00
0678.00       C* If subfile one is current, process print or display requests.                                 00/00/00
0679.00       C* First turn off error indicator if labels for a PO were printed                                00/00/00
0680.00       C* on previous pass.                                                                             00/00/00
0681.00       C*                                                                                               00/00/00
0682.00       C     FLGC01        IFEQ      *ON                                                                00/00/00
0683.00       C                   MOVE      *OFF          *IN44                                                00/00/00
0684.00       C                   MOVE      *OFF          *IN45                                                00/00/00
0685.00       C                   MOVE      *OFF          *IN49                                                00/00/00
0686.00       C                   SETOFF                                       60                              00/00/00
0687.00       C                   MOVE      *BLANK        S1SEL                                                00/00/00
0688.00       C     *IN60         DOWEQ     '0'                                                                00/00/00
0689.00       C     S1SEL         ANDEQ     *BLANK                                                             00/00/00
0690.00       C                   READC     S01                                    60                          00/00/00
0691.00       C*                                                                                               00/00/00
0692.00       C     *IN60         IFEQ      *OFF                                                               00/00/00
0693.00       C     S1SEL         ANDEQ     *BLANKS                                                            00/00/00
0694.00       C                   MOVE      *OFF          *IN40                                                00/00/00
0695.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0696.00       C                   MOVE      *OFF          *IN42                                                00/00/00
0697.00       C                   MOVE      *OFF          *IN43                                                00/00/00
0698.00       C                   MOVE      *OFF          *IN46                                                00/00/00
0699.00       C                   MOVE      *OFF          *IN48                                                00/00/00
0700.00       C*                                                                                               00/00/00
0701.00       C     H1CANC        IFEQ      'Y'                                                                00/00/00
0702.00       C                   MOVE      *ON           *IN51                                                00/00/00
0703.00       C                   ELSE                                                                         00/00/00
0704.00       C                   MOVE      *OFF          *IN51                                                00/00/00
0705.00       C                   ENDIF                                                                        00/00/00
0706.00       C*                                                                                               00/00/00
0707.00       C                   SETOFF                                       25        SFLNXTCHG             00/00/00
0708.00       C                   UPDATE    S01                                                                00/00/00
0709.00       C                   ENDIF                                                                        00/00/00
0710.00       C*                                                                                               00/00/00
0711.00       C                   ENDDO                                                  DOW                   00/00/00
0712.00       C*                                                                                               00/00/00
0713.00       C     S1SEL         IFEQ      'X'                                                                00/00/00
0714.00       C     S1SEL         OREQ      'P'                                                                00/00/00
0715.00       C     S1SEL         OREQ      'C'                                                                00/00/00
0716.00       C                   Z-ADD     S1VEND        WKVEND                                               00/00/00
0717.00       C                   Z-ADD     S1SUFF        WKSUFF                                               00/00/00
0718.00       C*                                                                                               00/00/00
0719.00       C     VMKEY2        CHAIN     INVMSTR                            72                              00/00/00
0720.00       C     *IN72         IFEQ      '1'                                                                00/00/00
0721.00       C     VMKEY         CHAIN     INVMST7                            72                              00/00/00
0722.00       C     *IN72         IFEQ      '1'                                                                00/00/00
0723.00       C                   MOVE      *BLANKS       VMNAME                                               00/00/00
0724.00       C                   ENDIF                                                  *IN72=1               00/00/00
0725.00       C                   ENDIF                                                  *IN72=1               00/00/00
0726.00       C*                                                                                               00/00/00
0727.00       C*                                                                                               00/00/00
0728.00       C     H1CANC        IFEQ      'Y'                                                                00/00/00
0729.00       C                   MOVE      *ON           *IN51                                                00/00/00
0730.00       C                   ELSE                                                                         00/00/00
0731.00       C                   MOVE      *OFF          *IN51                                                00/00/00
0732.00       C                   ENDIF                                                                        00/00/00
0733.00       C*                                                                                               00/00/00
0734.00       C*                                                                                               00/00/00
0735.00       C* "X" to display cigarette labels for PO                                                        00/00/00
0736.00       C*                                                                                               00/00/00
0737.00       C                   SELECT                                                                       00/00/00
0738.00       C*                                                                                               00/00/00
0739.00       C     S1SEL         WHENEQ    'X'                                                                00/00/00
0740.00       C*                                                                                               00/00/00
0741.00       C                   SETON                                        25        SFLNXTCHG             00/00/00
0742.00       C                   MOVE      *OFF          *IN40                                                00/00/00
0743.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0744.00       C                   MOVE      *OFF          *IN42                                                00/00/00
0745.00       C                   MOVE      *OFF          *IN43                                                00/00/00
0746.00       C                   MOVE      *OFF          *IN44                                                00/00/00
0747.00       C*                                                                                               00/00/00
0748.00       C     S1PRDT        IFGT      0                                                                  00/00/00
0749.00       C     H1CNDT        ORGT      0                                                                  00/00/00
0750.00       C*                                                                                               00/00/00
0751.00       C     H1CNDT        IFGT      0                                                                  00/00/00
0752.00       C     H1CANC        OREQ      'Y'                                                                00/00/00
0753.00       C                   MOVE      *ON           *IN51                                                00/00/00
0754.00       C                   ELSE                                                                         00/00/00
0755.00       C                   MOVE      *OFF          *IN51                                                00/00/00
0756.00       C                   ENDIF                                                                        00/00/00
0757.00       C*                                                                                               00/00/00
0758.00       C                   MOVE      ' '           S1SEL                                                00/00/00
0759.00       C                   UPDATE    S01                                                                00/00/00
0760.00       C                   SETOFF                                           25                          00/00/00
0761.00       C*                                                                                               00/00/00
0762.00       C                   Z-ADD     W1PONO        P1PONO                                               00/00/00
0763.00       C                   Z-ADD     0             P1LINO                                               00/00/00
0764.00       C                   MOVE      'CLP'         P1OPTN                                               00/00/00
0765.00       C*                                                                                               00/00/00
0766.00       C                   CALL      'INR1044Z'                                                         25/12/22
0767.00       C                   PARM                    P1OPTN                                               00/00/00
0768.00       C     *IN03         PARM      *IN03         #IN03             1                                  09/05/27
0769.00       C                   PARM                    P1PONO           17 5                                25/12/22
0770.00       C                   PARM                    P1LINO           15 5                                25/12/22
0771.00       C*                                                                                               00/00/00
0772.00       C     P1OPTN        IFNE      'CLP'                                                              00/00/00
0773.00       C                   MOVE      P1OPTN        C1OPTN                                               00/00/00
0774.00       C                   ENDIF                                                                        00/00/00
0775.00       C*                                                                                               00/00/00
0776.00       C                   ELSE                                                                         00/00/00
0777.00       C*                                                                                               00/00/00
0778.00       C* ERROR - user keyed 'X' to display labels for the PO but no                                    00/00/00
0779.00       C* labels exist.                                                                                 00/00/00
0780.00       C*                                                                                               00/00/00
0781.00       C                   MOVE      *ON           *IN40                                                00/00/00
0782.00       C*                                                                                               00/00/00
0783.00       C*                                                                                               00/00/00
0784.00       C                   SETON                                        25        SFLNXTCHG             00/00/00
0785.00       C                   UPDATE    S01                                                                00/00/00
0786.00       C                   SETOFF                                       25        SFLNXTCHG             00/00/00
0787.00       C*                                                                                               00/00/00
0788.00       C*                                                                                               00/00/00
0789.00       C                   ENDIF                                                                        00/00/00
0790.00       C*                                                                                               00/00/00
0791.00       C*                                                                                               00/00/00
0792.00       C*                                                                                               00/00/00
0793.00       C* "P" entered to print labels for the PO.  Don't allow print                                    00/00/00
0794.00       C* if already printed, not full distro, if PO recv or if                                         00/00/00
0795.00       C* invalid printed selected.                                                                     00/00/00
0796.00       C*                                                                                               00/00/00
0797.00       C     S1SEL         WHENEQ    'P'                                                                00/00/00
0798.00       C*                                                                                               00/00/00
0799.00       C*                                                                                               00/00/00
0800.00       C                   MOVE      *OFF          *IN40                                                00/00/00
0801.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0802.00       C                   MOVE      *OFF          *IN42                                                00/00/00
0803.00       C                   MOVE      *OFF          *IN43                                                00/00/00
0804.00       C*                                                                                               00/00/00
0805.00       C                   MOVE      'Y'           PRTOK             1                                  00/00/00
0806.00       C*                                                                                               00/00/00
0807.00       C                   SELECT                                                                       00/00/00
0808.00       C     S1RECV        WHENEQ    'Y'                                                                00/00/00
0809.00       C                   MOVE      *ON           *IN41                                                00/00/00
0810.00       C                   MOVE      'N'           PRTOK                                                00/00/00
0811.00       C     S1FULL        WHENEQ    'N'                                                                00/00/00
0812.00       C                   MOVE      *ON           *IN42                                                00/00/00
0813.00       C                   MOVE      'N'           PRTOK                                                00/00/00
0814.00       C     S1PRDT        WHENGT    0                                                                  00/00/00
0815.00       C                   MOVE      *ON           *IN43                                                00/00/00
0816.00       C                   MOVE      'N'           PRTOK                                                00/00/00
0817.00       C                   ENDSL                                                                        00/00/00
0818.00       C*                                                                                               00/00/00
0819.00       C*                                                                                               00/00/00
0820.00       C* If allowed to print PO, check printer.  If no errors, open                                    00/00/00
0821.00       C* INP1031 each time a PO is printed; one spool file per PO.                                     00/00/00
0822.00       C*                                                                                               00/00/00
0823.00       C     PRTOK         IFEQ      'Y'                                                                00/00/00
0824.00       C                   MOVE      *OFF          *IN44                                                00/00/00
0825.00       C                   MOVE      '*'           SVPNTR                                               00/00/00
0826.00       C                   MOVE      '*'           WKPNTR                                               10/01/25
0827.00       C                   EXSR      EDTPRT                                                             00/00/00
0828.00       C     *IN44         IFEQ      *ON                                                                00/00/00
0829.00       C                   MOVE      'N'           PRTOK                                                00/00/00
0830.00       C                   ENDIF                                                                        00/00/00
0831.00       C                   ENDIF                                                                        00/00/00
0832.00       C*                                                                                               00/00/00
0833.00       C*                                                                                               00/00/00
0834.00       C     PRTOK         IFEQ      'Y'                                                                00/00/00
0835.00       C*                                                                                               00/00/00
0836.00       C* Save keys to reset to next record if roll pressed                                             00/00/00
0837.00       C*                                                                                               00/00/00
0838.00       C                   Z-ADD     PMVEND        SVVEND                                               00/00/00
0839.00       C                   Z-ADD     PMSUFF        SVSUFF                                               00/00/00
0840.00       C                   Z-ADD     PMPONO        SVPONO                                               00/00/00
0841.00       C                   Z-ADD     PMARDT        SVARDT                                               00/00/00
0842.00       C*                                                                                               00/00/00
0843.00       C*                                                                                               00/00/00
0844.00       C     PMKEY3        CHAIN     INPMSTR                            74                              00/00/00
0845.00       C     *IN74         IFEQ      *OFF                                                               00/00/00
0846.00       C*                                                                                               00/00/00
0847.00       C*                                                                                               00/00/00
0848.00       C* Perform print and display message "Print Complete"                                            00/00/00
0849.00       C*                                                                                               00/00/00
0850.00       C                   EXSR      LABPRT                                                             00/00/00
0851.00       C*                                                                                               00/00/00
0852.00       C                   MOVE      *OFF          *IN40                                                00/00/00
0853.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0854.00       C                   MOVE      *OFF          *IN42                                                00/00/00
0855.00       C                   MOVE      *OFF          *IN43                                                00/00/00
0856.00       C                   MOVE      *ON           *IN45                                                00/00/00
0857.00       C                   MOVE      *OFF          *IN49                                                00/00/00
0858.00       C                   SETON                                        25        SFLNXTCHG             00/00/00
0859.00       C                   MOVE      ' '           S1SEL                                                00/00/00
0860.00       C                   EXSR      GETTIM                                                             00/00/00
0861.00       C                   MOVE      TDAT          S1PRDT                                               00/00/00
0862.00       C                   Z-ADD     0             H1CNDT                                               00/00/00
0863.00       C*                                                                                               00/00/00
0864.00       C* If subsequent print (labels previously canceled) then RI PONO                                 00/00/00
0865.00       C*                                                                                               00/00/00
0866.00       C     WKCANC        IFEQ      'Y'                                                                00/00/00
0867.00       C                   MOVE      *ON           *IN51                                                00/00/00
0868.00       C                   ELSE                                                                         00/00/00
0869.00       C                   MOVE      *OFF          *IN51                                                00/00/00
0870.00       C                   ENDIF                                                                        00/00/00
0871.00       C*                                                                                               00/00/00
0872.00       C                   UPDATE    S01                                                                00/00/00
0873.00       C                   SETOFF                                           25                          00/00/00
0874.00       C*                                                                                               00/00/00
0875.00       C                   ENDIF                                                  *IN74 = OFF           00/00/00
0876.00       C*                                                                                               00/00/00
0877.00       C                   CALLP     closeZebraPrinterFile()                                            24/05/16
0878.00       C*                                                                                               00/00/00
0879.00       C     *IN29         IFEQ      *OFF                                                               00/00/00
0880.00       C                   EXSR      RSETPM                                                             00/00/00
0881.00       C                   ENDIF                                                                        00/00/00
0882.00       C*                                                                                               00/00/00
0883.00       C*                                                                                               00/00/00
0884.00       C                   ELSE                                                                         00/00/00
0885.00       C*                                                                                               00/00/00
0886.00       C* ERROR - user keyed 'P' to print labels for the PO but labels                                  00/00/00
0887.00       C* have already been printed, full distro doesn't exist, the                                     00/00/00
0888.00       C* PO has already been received or invalid printer specified                                     00/00/00
0889.00       C*                                                                                               00/00/00
0890.00       C*                                                                                               00/00/00
0891.00       C     H1CNDT        IFGT      0                                                                  00/00/00
0892.00       C     H1CANC        OREQ      'Y'                                                                00/00/00
0893.00       C                   MOVE      *ON           *IN51                                                00/00/00
0894.00       C                   ELSE                                                                         00/00/00
0895.00       C                   MOVE      *OFF          *IN51                                                00/00/00
0896.00       C                   ENDIF                                                                        00/00/00
0897.00       C*                                                                                               00/00/00
0898.00       C*                                                                                               00/00/00
0899.00       C                   SETON                                        25        SFLNXTCHG             00/00/00
0900.00       C                   UPDATE    S01                                                                00/00/00
0901.00       C                   SETOFF                                       25        SFLNXTCHG             00/00/00
0902.00       C*                                                                                               00/00/00
0903.00       C*                                                                                               00/00/00
0904.00       C                   ENDIF                                                  PRTOK = 'Y'           00/00/00
0905.00       C*                                                                                               00/00/00
0906.00       C*                                                                                               00/00/00
0907.00       C*                                                                                               00/00/00
0908.00       C*                                                                                               00/00/00
0909.00       C* "C" entered to cancel all labels for the PO.  Verify that                                     00/00/00
0910.00       C* labels exist and that no labels on a license.                                                 00/00/00
0911.00       C*                                                                                               00/00/00
0912.00       C     S1SEL         WHENEQ    'C'                                                                00/00/00
0913.00       C*                                                                                               00/00/00
0914.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0915.00       C                   MOVE      *OFF          *IN46                                                00/00/00
0916.00       C                   MOVE      *OFF          *IN48                                                00/00/00
0917.00       C*                                                                                               00/00/00
0918.00       C                   MOVE      'L'           WKSTAT            1                                  00/00/00
0919.00       C     LBKEY3        SETLL     INCGLBR32                              71                          04/09/04
0920.00       C*                                                                                               00/00/00
0921.00       C*                                                                                               00/00/00
0922.00       C     S1PRDT        IFGT      0                                                                  00/00/00
0923.00       C     S1RECV        ANDEQ     'N'                                                                00/00/00
0924.00       C     *IN71         ANDEQ     *OFF                                                               00/00/00
0925.00       C*                                                                                               00/00/00
0926.00       C*                                                                                               00/00/00
0927.00       C* Save keys to reset to next record if roll pressed                                             00/00/00
0928.00       C*                                                                                               00/00/00
0929.00       C                   Z-ADD     PMVEND        SVVEND                                               00/00/00
0930.00       C                   Z-ADD     PMSUFF        SVSUFF                                               00/00/00
0931.00       C                   Z-ADD     PMPONO        SVPONO                                               00/00/00
0932.00       C                   Z-ADD     PMARDT        SVARDT                                               00/00/00
0933.00       C*                                                                                               00/00/00
0934.00       C*                                                                                               00/00/00
0935.00       C     PMKEY3        CHAIN     INPMSTR                            74                              00/00/00
0936.00       C     *IN74         IFEQ      *OFF                                                               00/00/00
0937.00       C*                                                                                               00/00/00
0938.00       C*                                                                                               00/00/00
0939.00       C* Update labels status to "D" and display msg "Delete Complete"                                 00/00/00
0940.00       C*                                                                                               00/00/00
0941.00       C                   EXSR      LABCNC                                                             00/00/00
0942.00       C*                                                                                               00/00/00
0943.00       C                   MOVE      *OFF          *IN45                                                00/00/00
0944.00       C                   MOVE      *OFF          *IN41                                                00/00/00
0945.00       C                   MOVE      *OFF          *IN46                                                00/00/00
0946.00       C                   MOVE      *OFF          *IN48                                                00/00/00
0947.00       C                   MOVE      *ON           *IN49                                                00/00/00
0948.00       C                   SETON                                        25        SFLNXTCHG             00/00/00
0949.00       C                   MOVE      ' '           S1SEL                                                00/00/00
0950.00       C                   EXSR      GETTIM                                                             00/00/00
0951.00       C                   Z-ADD     0             S1PRDT                                               00/00/00
0952.00       C                   Z-ADD     WKCDAT        H1CNDT                                               00/00/00
0953.00       C                   MOVE      'Y'           H1CANC                                               00/00/00
0954.00       C                   MOVE      *ON           *IN51                                                00/00/00
0955.00       C                   UPDATE    S01                                                                00/00/00
0956.00       C                   SETOFF                                           25                          00/00/00
0957.00       C*                                                                                               00/00/00
0958.00       C                   ENDIF                                                  *IN74 = OFF           00/00/00
0959.00       C*                                                                                               00/00/00
0960.00       C*                                                                                               00/00/00
0961.00       C     *IN29         IFEQ      *OFF                                                               00/00/00
0962.00       C                   EXSR      RSETPM                                                             00/00/00
0963.00       C                   ENDIF                                                                        00/00/00
0964.00       C*                                                                                               00/00/00
0965.00       C*                                                                                               00/00/00
0966.00       C                   ELSE                                                                         00/00/00
0967.00       C*                                                                                               00/00/00
0968.00       C*                                                                                               00/00/00
0969.00       C* ERROR - user keyed 'C' to delete labels for the PO but labels                                 00/00/00
0970.00       C* haven't been printed or at least one label has been placed                                    00/00/00
0971.00       C* on a license.                                                                                 00/00/00
0972.00       C*                                                                                               00/00/00
0973.00       C                   SELECT                                                                       00/00/00
0974.00       C     S1PRDT        WHENEQ    0                                                                  00/00/00
0975.00       C                   MOVE      *ON           *IN46                                                00/00/00
0976.00       C     S1RECV        WHENEQ    'Y'                                                                00/00/00
0977.00       C                   MOVE      *ON           *IN41                                                00/00/00
0978.00       C     *IN71         WHENEQ    *ON                                                                00/00/00
0979.00       C                   MOVE      *ON           *IN48                                                00/00/00
0980.00       C                   ENDSL                                                                        00/00/00
0981.00       C*                                                                                               00/00/00
0982.00       C*                                                                                               00/00/00
0983.00       C                   SETON                                        25        SFLNXTCHG             00/00/00
0984.00       C                   UPDATE    S01                                                                00/00/00
0985.00       C                   SETOFF                                       25        SFLNXTCHG             00/00/00
0986.00       C*                                                                                               00/00/00
0987.00       C*                                                                                               00/00/00
0988.00       C                   ENDIF                                                  S1PRDT,S1FULL         00/00/00
0989.00       C*                                                                                               00/00/00
0990.00       C                   ENDSL                                                                        00/00/00
0991.00       C*                                                                                               00/00/00
0992.00       C*                                                                                               00/00/00
0993.00       C*                                                                                               00/00/00
0994.00       C*                                                                                               00/00/00
0995.00       C     RR1           IFLE      15                                                                 00/00/00
0996.00       C*                                                                                               00/00/00
0997.00       C                   Z-ADD     1             C1DSPR                                               00/00/00
0998.00       C*                                                                                               00/00/00
0999.00       C                   ELSE                                                                         00/00/00
1000.00       C*                                                                                               00/00/00
1001.00       C                   Z-ADD     0             WKREM             5 0                                00/00/00
1002.00       C     RR1           DIV       15            WKDIV             3 0                                00/00/00
1003.00       C                   MVR                     WKREM                                                00/00/00
1004.00       C     WKREM         IFEQ      0                                                                  00/00/00
1005.00       C                   SUB       1             WKDIV                                                00/00/00
1006.00       C                   ENDIF                                                                        00/00/00
1007.00       C     WKDIV         MULT      15            C1DSPR                                               00/00/00
1008.00       C                   ADD       1             C1DSPR                                               00/00/00
1009.00       C*                                                                                               00/00/00
1010.00       C                   ENDIF                                                                        00/00/00
1011.00       C*                                                                                               00/00/00
1012.00       C*                                                                                               00/00/00
1013.00       C                   END                                                    S1SEL=X               00/00/00
1014.00       C*                                                                                               00/00/00
1015.00       C*                                                                                               00/00/00
1016.00       C                   ENDIF                                                                        00/00/00
1017.00       C*                                                                                               00/00/00
1018.00       C*                                                    *IN13=0 AND                                00/00/00
1019.00       C                   ENDSL                                                  *IN13=0 AND           00/00/00
1020.00       C*                                                                                               00/00/00
1021.00       C     FLGC01        IFEQ      *OFF                                                               00/00/00
1022.00       C                   MOVE      *OFF          *IN27                                                00/00/00
1023.00       C                   ELSE                                                                         00/00/00
1024.00       C                   MOVE      *ON           *IN27                                                00/00/00
1025.00       C                   ENDIF                                                                        00/00/00
1026.00       C*                                                                                               00/00/00
1027.00       C                   ELSE                                                                         00/00/00
1028.00       C*                                                                                               00/00/00
1029.00       C                   EXSR      CLRC01                                                             00/00/00
1030.00       C*                                                                                               00/00/00
1031.00       C                   ENDIF                                                                        00/00/00
1032.00       C*                                                                                               00/00/00
1033.00       C     *IN07         IFEQ      *ON                                                                00/00/00
1034.00       C                   MOVE      *OFF          *IN07                                                00/00/00
1035.00       C                   ENDIF                                                                        00/00/00
1036.00       C     *IN08         IFEQ      *ON                                                                00/00/00
1037.00       C                   MOVE      *OFF          *IN08                                                00/00/00
1038.00       C                   ENDIF                                                                        00/00/00
1039.00       C*                                                                                               00/00/00
1040.00       C*                                                                                               00/00/00
1041.00       C     FLGC01        IFEQ      *ON                                                                00/00/00
1042.00       C                   WRITE     R02                                                                00/00/00
1043.00       C                   ENDIF                                                                        00/00/00
1044.00       C*                                                                                               00/00/00
1045.00       C*                                                                                               00/00/00
1046.00       C                   ENDSR                                                                        00/00/00
1047.00       C*                                                                                               00/00/00
1048.00        /EJECT                                                                                          00/00/00
1049.00        ************************** EDITH ********************************                               00/00/00
1050.00        *   SUBROUTINE TO EDIT HEADER INFORMATION                       *                               00/00/00
1051.00        ************************** EDITH ********************************                               00/00/00
1052.00        *                                                                                               00/00/00
1053.00       C     EDITH         BEGSR                                                                        00/00/00
1054.00       C*                                                                                               00/00/00
1055.00       C                   MOVE      *OFF          *IN32                                                00/00/00
1056.00       C                   MOVE      *OFF          *IN36                                                00/00/00
1057.00       C                   MOVE      *OFF          *IN37                                                00/00/00
1058.00       C                   MOVE      *OFF          *IN40                                                00/00/00
1059.00       C                   MOVE      *OFF          *IN42                                                00/00/00
1060.00       C                   MOVE      *OFF          *IN43                                                00/00/00
1061.00       C                   MOVE      *OFF          *IN44                                                00/00/00
1062.00       C                   MOVE      *OFF          *IN45                                                00/00/00
1063.00       C                   MOVE      *OFF          *IN46                                                00/00/00
1064.00       C                   MOVE      *OFF          *IN48                                                00/00/00
1065.00       C                   MOVE      *OFF          *IN49                                                00/00/00
1066.00       C                   MOVE      *OFF          *IN62                                                00/00/00
1067.00       C                   MOVE      *OFF          *IN63                                                00/00/00
1068.00       C                   MOVE      *OFF          *IN64                                                00/00/00
1069.00       C*                                                                                               00/00/00
1070.00       C*                                                                                               00/00/00
1071.00       C                   SELECT                                                                       00/00/00
1072.00       C*                                                                                               00/00/00
1073.00       C*                                                                                               00/00/00
1074.00       C     C1VEND        WHENNE    0                                                                  00/00/00
1075.00       C     C1PONO        ANDNE     0                                                                  00/00/00
1076.00       C     C1VEND        ORNE      0                                                                  00/00/00
1077.00       C     C1DATE        ANDNE     0                                                                  00/00/00
1078.00       C     C1PONO        ORNE      0                                                                  00/00/00
1079.00       C     C1DATE        ANDNE     0                                                                  00/00/00
1080.00       C     C1VEND        OREQ      0                                                                  00/00/00
1081.00       C     C1PONO        ANDEQ     0                                                                  00/00/00
1082.00       C     C1DATE        ANDEQ     0                                                                  00/00/00
1083.00       C                   MOVE      *ON           *IN32                                                00/00/00
1084.00       C                   MOVE      'Y'           ERROR                                                00/00/00
1085.00       C*                                                                                               00/00/00
1086.00       C*                                                                                               00/00/00
1087.00       C                   OTHER                                                                        00/00/00
1088.00       C*                                                                                               00/00/00
1089.00       C* If position date or filter date is entered, validate                                          00/00/00
1090.00       C*                                                                                               00/00/00
1091.00       C     C1DATE        IFNE      0                                                                  00/00/00
1092.00       C     C1PRDT        ORNE      0                                                                  00/00/00
1093.00       C*                                                                                               00/00/00
1094.00       C     C1DATE        IFLT      0                                            NEGATIVE DTE          00/00/00
1095.00       C     C1PRDT        ORLT      0                                                                  00/00/00
1096.00       C                   MOVE      'Y'           ERROR                                                00/00/00
1097.00       C     C1DATE        IFLT      0                                                                  00/00/00
1098.00       C                   MOVE      *ON           *IN36                                                00/00/00
1099.00       C                   ELSE                                                                         00/00/00
1100.00       C                   MOVE      *ON           *IN37                                                00/00/00
1101.00       C                   ENDIF                                                                        00/00/00
1102.00       C                   ELSE                                                                         00/00/00
1103.00       C     1             DO        2             X                                                    00/00/00
1104.00       C                   Z-ADD     0             P1DATE            6 0                                00/00/00
1105.00       C     X             IFEQ      1                                                                  00/00/00
1106.00       C     C1DATE        ANDNE     0                                                                  00/00/00
1107.00       C                   Z-ADD     C1DATE        P1DATE                                               00/00/00
1108.00       C                   ENDIF                                                                        00/00/00
1109.00       C     X             IFEQ      2                                                                  00/00/00
1110.00       C     C1PRDT        ANDNE     0                                                                  00/00/00
1111.00       C     *IN36         ANDEQ     *OFF                                                               00/00/00
1112.00       C                   Z-ADD     C1PRDT        P1DATE                                               00/00/00
1113.00       C                   ENDIF                                                                        00/00/00
1114.00       C     P1DATE        IFNE      0                                                                  00/00/00
1115.00       C                   Z-ADD     P1DATE        PBEGDT                         Date Evaluated        00/00/00
1116.00       C                   MOVE      ' '           PERROR                         Reset  Errflag        00/00/00
1117.00       C                   Z-ADD     0             PENDDT                         Resulting date        00/00/00
1118.00       C                   CALL      'UTR100'                             93                            00/00/00
1119.00       C                   PARM                    PDAYS             5 0           DATE ADJUSTMENT      00/00/00
1120.00       C                   PARM                    PBEGDT            7 0           DATE IN              00/00/00
1121.00       C                   PARM                    PENDDT            7 0           DATE OUT             00/00/00
1122.00       C                   PARM                    PERROR            1             DATE FMT ERRFLAG     00/00/00
1123.00       C                   PARM                    PFMTIN            5             DATE IN FORMAT       00/00/00
1124.00       C                   PARM                    PFMTOT            5             DATE OUT FORMAT      00/00/00
1125.00       C*                                                                                               00/00/00
1126.00       C     PERROR        IFEQ      'Y'                                          BAD DATE              00/00/00
1127.00       C     *IN93         OREQ      '1'                                                                00/00/00
1128.00       C                   MOVE      'Y'           ERROR                                                00/00/00
1129.00       C     X             IFEQ      1                                                                  00/00/00
1130.00       C                   MOVE      *ON           *IN36                                                00/00/00
1131.00       C                   ELSE                                                                         00/00/00
1132.00       C                   MOVE      *ON           *IN37                                                00/00/00
1133.00       C                   ENDIF                                                  X IFEQ 1              00/00/00
1134.00       C                   ENDIF                                                  PERROR = Y            00/00/00
1135.00       C                   ENDIF                                                  P1DATE <> 0           00/00/00
1136.00       C                   ENDDO                                                  1 DO 2 X              00/00/00
1137.00       C                   ENDIF                                                  DATE,PRDT< 0          00/00/00
1138.00       C                   ENDIF                                                  DATE,PRDT<>0          00/00/00
1139.00       C*                                                                                               00/00/00
1140.00       C*                                                                                               00/00/00
1141.00       C*                                                                                               00/00/00
1142.00       C*                                                                                               00/00/00
1143.00       C*                                                                                               00/00/00
1144.00       C                   MOVE      *OFF          *IN68                                                00/00/00
1145.00       C*                                                                                               00/00/00
1146.00       C                   SELECT                                                                       00/00/00
1147.00       C*                                                                                               00/00/00
1148.00       C* Date error                                                                                    00/00/00
1149.00       C     *IN36         WHENEQ    *ON                                                                00/00/00
1150.00       C     *IN37         OREQ      *ON                                                                00/00/00
1151.00       C*                                                                                               00/00/00
1152.00       C*                                                                                               00/00/00
1153.00       C*                                                                                               00/00/00
1154.00       C     C1VEND        WHENGT    0                                                                  00/00/00
1155.00       C                   MOVE      'DV'          WKKEYS            2                                  00/00/00
1156.00       C     PMKEY         SETLL     INPMSTR                                61                          00/00/00
1157.00       C     PMKEY4        READE     INPMSTR                                68                          00/00/00
1158.00       C     *IN68         DOWEQ     *OFF                                                               00/00/00
1159.00       C     PMFLGL        ANDNE     'Y'                                                                00/00/00
1160.00       C     PMKEY4        READE     INPMSTR                                68                          00/00/00
1161.00       C                   ENDDO                                                                        00/00/00
1162.00       C     *IN68         IFEQ      *ON                                                                00/00/00
1163.00       C                   MOVE      *ON           *IN62                                                00/00/00
1164.00       C                   MOVE      'Y'           ERROR                                                00/00/00
1165.00       C                   ENDIF                                                                        00/00/00
1166.00       C*                                                                                               00/00/00
1167.00       C     C1PONO        WHENGT    0                                                                  00/00/00
1168.00       C                   MOVEL     C1WHSE        C1PONO                                               00/00/00
1169.00       C                   MOVE      'PO'          WKKEYS                                               00/00/00
1170.00       C                   MOVE      *OFF          SELREC            1                                  00/00/00
1171.00       C                   Z-ADD     C1PONO        C2PONO                                               00/00/00
1172.00       C     PMKEY1        SETLL     INPMSTR32                              61                          04/09/04
1173.00       C     C1WHSE        READE     INPMSTR32                              68                          04/09/04
1174.00       C     *IN68         IFEQ      *OFF                                                               00/00/00
1175.00       C     PMDEPT        ANDEQ     11                                                                 00/00/00
1176.00       C     PMFLGL        ANDEQ     'Y'                                                                00/00/00
1177.00       C                   MOVE      *ON           SELREC                                               00/00/00
1178.00       C                   ENDIF                                                                        00/00/00
1179.00       C     *IN68         DOWEQ     *OFF                                                               00/00/00
1180.00       C     SELREC        ANDEQ     *OFF                                                               00/00/00
1181.00       C     C1WHSE        READE     INPMSTR32                              68                          04/09/04
1182.00       C     *IN68         IFEQ      *OFF                                                               00/00/00
1183.00       C     PMDEPT        ANDEQ     11                                                                 00/00/00
1184.00       C     PMFLGL        ANDEQ     'Y'                                                                00/00/00
1185.00       C                   MOVE      *ON           SELREC                                               00/00/00
1186.00       C                   ENDIF                                                                        00/00/00
1187.00       C                   ENDDO                                                                        00/00/00
1188.00       C     *IN68         IFEQ      *ON                                                                00/00/00
1189.00       C                   MOVE      *ON           *IN63                                                00/00/00
1190.00       C                   MOVE      'Y'           ERROR                                                00/00/00
1191.00       C                   ENDIF                                                                        00/00/00
1192.00       C*                                                                                               00/00/00
1193.00       C                   MOVE      PMFLG7        PMFLG7                                               00/00/00
1194.00       C                   MOVE      PMFLGL        PMFLGL                                               00/00/00
1195.00       C*                                                                                               00/00/00
1196.00       C*                                                                                               00/00/00
1197.00       C     C1DATE        WHENGT    0                                                                  00/00/00
1198.00       C*                                                                                               00/00/00
1199.00       C*                                                                                               00/00/00
1200.00       C                   MOVE      'DT'          WKKEYS                                               00/00/00
1201.00       C                   MOVE      C1DATE        CVTMDY                                               00/00/00
1202.00       C                   EXSR      CVTM2Y                                                             00/00/00
1203.00       C                   MOVE      CVTYMD        WKDATE                                               00/00/00
1204.00       C     PMKEY2        SETLL     INPMSTR35                              61                          04/09/04
1205.00       C     PMKEY4        READE     INPMSTR35                              68                          04/09/04
1206.00       C     *IN68         DOWEQ     *OFF                                                               00/00/00
1207.00       C     PMFLGL        ANDNE     'Y'                                                                00/00/00
1208.00       C     PMKEY4        READE     INPMSTR35                              68                          04/09/04
1209.00       C                   ENDDO                                                                        00/00/00
1210.00       C     *IN68         IFEQ      *ON                                                                00/00/00
1211.00       C                   MOVE      *ON           *IN64                                                00/00/00
1212.00       C                   MOVE      'Y'           ERROR                                                00/00/00
1213.00       C                   ENDIF                                                                        00/00/00
1214.00       C*                                                                                               00/00/00
1215.00       C                   ENDSL                                                                        00/00/00
1216.00       C*                                                                                               00/00/00
1217.00       C*                                                                                               00/00/00
1218.00       C*                                                                                               00/00/00
1219.00       C                   ENDSL                                                                        00/00/00
1220.00       C*                                                                                               00/00/00
1221.00       C*                                                                                               00/00/00
1222.00       C                   ENDSR                                                                        00/00/00
1223.00        /EJECT                                                                                          00/00/00
1224.00        ************************** LOAD1 ********************************                               00/00/00
1225.00        *   SUBROUTINE TO LOAD ONE PAGE OF PO CIGARETTE SUBFILE         *                               00/00/00
1226.00        ************************** LOAD1 ********************************                               00/00/00
1227.00        *                                                                                               00/00/00
1228.00       C     LOAD1         BEGSR                                                                        00/00/00
1229.00       C*                                                                                               00/00/00
1230.00       C                   MOVE      *OFF          *IN50                                                00/00/00
1231.00       C                   Z-ADD     SVRR1         RR1               3 0                                00/00/00
1232.00       C                   Z-ADD     0             RRX               2 0                                00/00/00
1233.00       C     RR1           ADD       1             C1DSPR                                               00/00/00
1234.00       C                   MOVE      *BLANK        S1SEL                                                00/00/00
1235.00       C*                                                                                               00/00/00
1236.00       C*   CREATES ONE EMPTY S01 RECORD FOR CREATING NEW RTV                                           00/00/00
1237.00       C*                                                                                               00/00/00
1238.00       C*                                                                                               00/00/00
1239.00       C     *IN68         DOWEQ     '0'                                                                00/00/00
1240.00       C     RRX           ANDLT     15                                                                 00/00/00
1241.00       C     RR1           ANDLT     100                                                                00/00/00
1242.00       C*                                                                                               00/00/00
1243.00       C*                                                                                               00/00/00
1244.00       C                   EXSR      FILTER                                                             00/00/00
1245.00       C*                                                                                               00/00/00
1246.00       C*                                                                                               00/00/00
1247.00       C     WKDSPL        IFEQ      *BLANK                                                             00/00/00
1248.00       C                   ADD       1             RR1                                                  00/00/00
1249.00       C                   ADD       1             RRX                                                  00/00/00
1250.00       C                   Z-ADD     C1WHSE        W1WHSE                                               00/00/00
1251.00       C                   Z-ADD     PMPONO        W1PONO                                               00/00/00
1252.00       C                   MOVE      PMARDT        CVTYMD                                               00/00/00
1253.00       C                   MOVE      CVTYY1        CVTYY2                                               00/00/00
1254.00       C                   MOVE      CVTMDY        S1DATE                                               00/00/00
1255.00       C                   Z-ADD     PMVEND        S1VEND                                               00/00/00
1256.00       C                   Z-ADD     PMSUFF        S1SUFF                                               00/00/00
1257.00       C*                                                                                               00/00/00
1258.00       C*                                                                                               00/00/00
1259.00       C                   Z-ADD     S1VEND        WKVEND                                               00/00/00
1260.00       C                   Z-ADD     S1SUFF        WKSUFF                                               00/00/00
1261.00       C*                                                                                               00/00/00
1262.00       C     VMKEY2        CHAIN     INVMSTR                            72                              00/00/00
1263.00       C     *IN72         IFEQ      '1'                                                                00/00/00
1264.00       C     VMKEY         CHAIN     INVMST7                            72                              00/00/00
1265.00       C                   ENDIF                                                                        00/00/00
1266.00       C*                                                                                               00/00/00
1267.00       C     *IN72         IFEQ      *OFF                                                     R         00/00/00
1268.00       C                   MOVEL     VMNAME        S1NAME                                               00/00/00
1269.00       C                   ELSE                                                                         00/00/00
1270.00       C                   MOVE      *BLANKS       S1NAME                                               00/00/00
1271.00       C                   ENDIF                                                               -        00/00/00
1272.00       C*                                                                                               00/00/00
1273.00       C*                                                                                               00/00/00
1274.00       C*                                                                                               00/00/00
1275.00       C                   MOVE      *OFF          *IN40                                                00/00/00
1276.00       C                   MOVE      *OFF          *IN41                                                00/00/00
1277.00       C                   MOVE      *OFF          *IN42                                                00/00/00
1278.00       C                   MOVE      *OFF          *IN43                                                00/00/00
1279.00       C                   MOVE      *OFF          *IN45                                                00/00/00
1280.00       C                   MOVE      *OFF          *IN46                                                00/00/00
1281.00       C                   MOVE      *OFF          *IN48                                                00/00/00
1282.00       C                   MOVE      *OFF          *IN49                                                00/00/00
1283.00       C*                                                                                               00/00/00
1284.00       C                   WRITE     S01                                                                00/00/00
1285.00       C*                                                                                               00/00/00
1286.00       C*                                                                                               00/00/00
1287.00       C                   END                                                    TMFLG4=BLANK          00/00/00
1288.00       C*                                                                                               00/00/00
1289.00       C*                                                                                               00/00/00
1290.00       C                   EXSR      READPM                                                             00/00/00
1291.00       C*                                                                                               00/00/00
1292.00       C*                                                                                               00/00/00
1293.00       C                   ENDDO                                                  DOW                   00/00/00
1294.00       C*                                                                                               00/00/00
1295.00       C*                                                                                               00/00/00
1296.00       C*                                                                                               00/00/00
1297.00       C* CHECK IF MORE CIGARETTE PO'S TO DISPLAY                                                       00/00/00
1298.00       C*                                                                                               00/00/00
1299.00       C                   MOVE      'N'           WKDSPL                                               00/00/00
1300.00       C*                                                                                               00/00/00
1301.00       C     *IN68         DOWEQ     '0'                                                                00/00/00
1302.00       C     WKDSPL        ANDEQ     'N'                                                                00/00/00
1303.00       C*                                                                                               00/00/00
1304.00       C                   EXSR      FILTER                                                             00/00/00
1305.00       C*                                                                                               00/00/00
1306.00       C     WKDSPL        IFEQ      'N'                                                                00/00/00
1307.00       C                   EXSR      READPM                                                             00/00/00
1308.00       C                   ENDIF                                                                        00/00/00
1309.00       C*                                                                                               00/00/00
1310.00       C                   ENDDO                                                  DOW                   00/00/00
1311.00       C*                                                                                               00/00/00
1312.00       C*                                                                                               00/00/00
1313.00       C* If not end of file and run out of screen, save current document                               00/00/00
1314.00       C* keys to reset search (for roll) if selection made from subfile                                00/00/00
1315.00       C*                                                                                               00/00/00
1316.00       C     *IN68         IFEQ      '1'                                                                00/00/00
1317.00       C     RR1           OREQ      100                                                                00/00/00
1318.00       C                   SETON                                        29                              00/00/00
1319.00       C                   ENDIF                                                                        00/00/00
1320.00       C*                                                                                               00/00/00
1321.00       C     *IN29         IFEQ      '1'                                          DISPLAY MSG           00/00/00
1322.00       C     RR1           ANDGE     100                                          MAX 100 ITEMS         00/00/00
1323.00       C                   SETON                                        47                              00/00/00
1324.00       C                   END                                                                          00/00/00
1325.00       C                   Z-ADD     RR1           SVRR1                                                00/00/00
1326.00       C*                                                                                               00/00/00
1327.00       C                   ENDSR                                                                        00/00/00
1328.00        /EJECT                                                                                          00/00/00
1329.00        ************************** READPM *******************************                               00/00/00
1330.00        *   SUBROUTINE TO READ PO MASTER RECORD                         *                               00/00/00
1331.00        ************************** READPM *******************************                               00/00/00
1332.00        *                                                                                               00/00/00
1333.00       C     READPM        BEGSR                                                                        00/00/00
1334.00       C*                                                                                               00/00/00
1335.00       C*                                                                                               00/00/00
1336.00       C                   SELECT                                                                       00/00/00
1337.00       C*                                                                                               00/00/00
1338.00       C*                                                                                               00/00/00
1339.00       C     WKKEYS        WHENEQ    'DV'                                                               00/00/00
1340.00       C     PMKEY4        READE     INPMSTR                                68                          00/00/00
1341.00       C     *IN68         DOWEQ     *OFF                                                               00/00/00
1342.00       C     PMFLGL        ANDNE     'Y'                                                                00/00/00
1343.00       C     PMKEY4        READE     INPMSTR                                68                          00/00/00
1344.00       C                   ENDDO                                                                        00/00/00
1345.00       C*                                                                                               00/00/00
1346.00       C*                                                                                               00/00/00
1347.00       C     WKKEYS        WHENEQ    'PO'                                                               00/00/00
1348.00       C                   MOVE      *OFF          SELREC            1                                  00/00/00
1349.00       C     C1WHSE        READE     INPMSTR32                              68                          04/09/04
1350.00       C     *IN68         IFEQ      *OFF                                                               00/00/00
1351.00       C     PMDEPT        ANDEQ     11                                                                 00/00/00
1352.00       C     PMFLGL        ANDEQ     'Y'                                                                00/00/00
1353.00       C                   MOVE      *ON           SELREC                                               00/00/00
1354.00       C                   ENDIF                                                                        00/00/00
1355.00       C     *IN68         DOWEQ     *OFF                                                               00/00/00
1356.00       C     SELREC        ANDEQ     *OFF                                                               00/00/00
1357.00       C     C1WHSE        READE     INPMSTR32                              68                          04/09/04
1358.00       C     *IN68         IFEQ      *OFF                                                               00/00/00
1359.00       C     PMDEPT        ANDEQ     11                                                                 00/00/00
1360.00       C     PMFLGL        ANDEQ     'Y'                                                                00/00/00
1361.00       C                   MOVE      *ON           SELREC                                               00/00/00
1362.00       C                   ENDIF                                                                        00/00/00
1363.00       C                   ENDDO                                                                        00/00/00
1364.00       C*                                                                                               00/00/00
1365.00       C*                                                                                               00/00/00
1366.00       C     WKKEYS        WHENEQ    'DT'                                                               00/00/00
1367.00       C     PMKEY4        READE     INPMSTR35                              68                          04/09/04
1368.00       C     *IN68         DOWEQ     *OFF                                                               00/00/00
1369.00       C     PMFLGL        ANDNE     'Y'                                                                00/00/00
1370.00       C     PMKEY4        READE     INPMSTR35                              68                          04/09/04
1371.00       C                   ENDDO                                                                        00/00/00
1372.00       C*                                                                                               00/00/00
1373.00       C*                                                                                               00/00/00
1374.00       C                   ENDSL                                                                        00/00/00
1375.00       C*                                                                                               00/00/00
1376.00       C*                                                                                               00/00/00
1377.00       C                   ENDSR                                                                        00/00/00
1378.00        /EJECT                                                                                          00/00/00
1379.00        ************************** FILTER *******************************                               00/00/00
1380.00        *   SUBROUTINE TO INCLUDE/EXCLUDE INPMSTP BASED ON SCREEN DATA  *                               00/00/00
1381.00        ************************** FILTER *******************************                               00/00/00
1382.00       C*                                                                                               00/00/00
1383.00       C     FILTER        BEGSR                                                                        00/00/00
1384.00       C*                                                                                               00/00/00
1385.00       C*                                                                                               00/00/00
1386.00       C                   MOVE      ' '           WKDSPL            1                                  00/00/00
1387.00       C*                                                                                               00/00/00
1388.00       C*                                                                                               00/00/00
1389.00       C* See if the PO has been printed by checking for label records.                                 00/00/00
1390.00       C* If all label records for the PO have been deleted (status                                     00/00/00
1391.00       C* of "D"), the PO is considered to have not been printed -                                      00/00/00
1392.00       C* load the cancel date instead.                                                                 00/00/00
1393.00       C*                                                                                               00/00/00
1394.00       C                   Z-ADD     0             H1CNDT                                               00/00/00
1395.00       C                   MOVE      ' '           WKSTAT                                               00/00/00
1396.00       C                   MOVE      *ON           *IN71                                                00/00/00
1397.00       C*                                                                                               00/00/00
1398.00       C     *IN71         DOWEQ     *ON                                                                00/00/00
1399.00       C     WKSTAT        ANDNE     'X'                                                                00/00/00
1400.00       C     LBKEY1        CHAIN     INCGLBR32                          71                              04/09/04
1401.00       C     *IN71         IFEQ      *ON                                                                00/00/00
1402.00       C     WKSTAT        IFEQ      ' '                                                                00/00/00
1403.00       C                   MOVE      'L'           WKSTAT                                               00/00/00
1404.00       C                   ELSE                                                                         00/00/00
1405.00       C                   MOVE      'X'           WKSTAT                                               00/00/00
1406.00       C                   ENDIF                                                                        00/00/00
1407.00       C                   ENDIF                                                                        00/00/00
1408.00       C                   ENDDO                                                                        00/00/00
1409.00       C*                                                                                               00/00/00
1410.00       C     *IN71         IFEQ      '0'                                                                00/00/00
1411.00       C                   MOVE      LBADDT        CVTYMD                                               00/00/00
1412.00       C                   MOVE      CVTYY1        CVTYY2                                               00/00/00
1413.00       C                   MOVE      CVTMDY        S1PRDT                                               00/00/00
1414.00       C*                                                                                               00/00/00
1415.00       C* RI PONO IF PO LABELS HAVE BEEN CANCELLED                                                      00/00/00
1416.00       C*                                                                                               00/00/00
1417.00       C     LBFLG2        IFEQ      'Y'                                                                00/00/00
1418.00       C                   MOVE      *ON           *IN51                                                00/00/00
1419.00       C                   MOVE      'Y'           H1CANC                                               00/00/00
1420.00       C                   ELSE                                                                         00/00/00
1421.00       C                   MOVE      *OFF          *IN51                                                00/00/00
1422.00       C                   MOVE      ' '           H1CANC                                               00/00/00
1423.00       C                   ENDIF                                                                        00/00/00
1424.00       C*                                                                                               00/00/00
1425.00       C                   ELSE                                                                         00/00/00
1426.00       C                   Z-ADD     0             S1PRDT                                               00/00/00
1427.00       C                   MOVE      'D'           WKSTAT                                               00/00/00
1428.00       C     LBKEY1        CHAIN     INCGLBR32                          71                              04/09/04
1429.00       C     *IN71         IFEQ      '0'                                                                00/00/00
1430.00       C                   Z-ADD     LBSTDT        H1CNDT                                               00/00/00
1431.00       C                   MOVE      *ON           *IN51                                                00/00/00
1432.00       C                   MOVE      'Y'           H1CANC                                               00/00/00
1433.00       C                   ELSE                                                                         00/00/00
1434.00       C                   MOVE      *OFF          *IN51                                                00/00/00
1435.00       C                   MOVE      ' '           H1CANC                                               00/00/00
1436.00       C                   ENDIF                                                                        00/00/00
1437.00       C                   ENDIF                                                                        00/00/00
1438.00       C*                                                                                               00/00/00
1439.00       C*                                                                                               00/00/00
1440.00       C                   MOVE      'N'           S1RECV                                               00/00/00
1441.00       C                   MOVE      'Y'           S1FULL                                               00/00/00
1442.00       C     PDKEY         CHAIN     INPDTRR                            71                              00/00/00
1443.00       C     *IN71         IFEQ      *OFF                                                               00/00/00
1444.00       C     *IN71         DOWEQ     '0'                                                                00/00/00
1445.00       C     PDQORD        IFNE      PDQOHS                                                             00/00/00
1446.00       C                   MOVE      'N'           S1FULL                                               00/00/00
1447.00       C                   ENDIF                                                                        00/00/00
1448.00       C     PDVREC        IFGT      0                                                                  00/00/00
1449.00       C                   MOVE      'Y'           S1RECV                                               00/00/00
1450.00       C                   ENDIF                                                                        00/00/00
1451.00       C     PDKEY         READE     INPDTRR                                71                          00/00/00
1452.00       C                   ENDDO                                                                        00/00/00
1453.00       C                   ELSE                                                                         00/00/00
1454.00       C                   MOVE      'N'           S1FULL                                               00/00/00
1455.00       C                   ENDIF                                                                        00/00/00
1456.00       C*                                                                                               00/00/00
1457.00       C                   MOVE      'L'           WKSTAT                                               00/00/00
1458.00       C*                                                                                               00/00/00
1459.00       C     LBKEY1        SETLL     INCGLBR32                              71                          04/09/04
1460.00       C     *IN71         IFEQ      '1'                                                                00/00/00
1461.00       C                   MOVE      'Y'           S1LICN                                               00/00/00
1462.00       C                   ELSE                                                                         00/00/00
1463.00       C                   MOVE      'N'           S1LICN                                               00/00/00
1464.00       C                   ENDIF                                                                        00/00/00
1465.00       C*                                                                                               00/00/00
1466.00       C*                                                                                               00/00/00
1467.00       C*                                                                                               00/00/00
1468.00       C     C1RECV        IFNE      ' '                                                                00/00/00
1469.00       C     S1RECV        ANDNE     C1RECV                                                             00/00/00
1470.00       C                   MOVE      'N'           WKDSPL                                               00/00/00
1471.00       C                   ENDIF                                                                        00/00/00
1472.00       C*                                                                                               00/00/00
1473.00       C     C1FULL        IFNE      ' '                                                                00/00/00
1474.00       C     S1FULL        ANDNE     C1FULL                                                             00/00/00
1475.00       C                   MOVE      'N'           WKDSPL                                               00/00/00
1476.00       C                   ENDIF                                                                        00/00/00
1477.00       C*                                                                                               00/00/00
1478.00       C     C1LICN        IFNE      ' '                                                                00/00/00
1479.00       C     S1LICN        ANDNE     C1LICN                                                             00/00/00
1480.00       C                   MOVE      'N'           WKDSPL                                               00/00/00
1481.00       C                   ENDIF                                                                        00/00/00
1482.00       C*                                                                                               00/00/00
1483.00       C     C1PRDT        IFGT      0                                                                  00/00/00
1484.00       C     S1PRDT        IFNE      C1PRDT                                                             00/00/00
1485.00       C                   MOVE      'N'           WKDSPL                                               00/00/00
1486.00       C                   ENDIF                                                                        00/00/00
1487.00       C                   ENDIF                                                                        00/00/00
1488.00       C*                                                                                               00/00/00
1489.00       C     C1LINO        IFGT      0                                                                  00/00/00
1490.00       C     LBKEY2        SETLL     INCGLBR31                              71                          04/09/04
1491.00       C     *IN71         IFEQ      '0'                                                                00/00/00
1492.00       C                   MOVE      'N'           WKDSPL                                               00/00/00
1493.00       C                   ENDIF                                                                        00/00/00
1494.00       C                   ENDIF                                                                        00/00/00
1495.00       C*                                                                                               00/00/00
1496.00       C*                                                                                               00/00/00
1497.00       C                   ENDSR                                                                        00/00/00
1498.00       C*                                                                                               00/00/00
1499.00        /EJECT                                                                                          00/00/00
1500.00        ************************** CLRR01 *******************************                               00/00/00
1501.00        *   CLEAR SCREEN R01                                            *                               00/00/00
1502.00        ************************** CLRR01 *******************************                               00/00/00
1503.00       C*                                                                                               00/00/00
1504.00       C     CLRC01        BEGSR                                                                        00/00/00
1505.00       C*                                                                                               00/00/00
1506.00       C*                                                                                               00/00/00
1507.00       C                   MOVE      *OFF          *IN32                                                00/00/00
1508.00       C                   MOVE      *OFF          *IN44                                                00/00/00
1509.00       C                   MOVE      *OFF          *IN86                                                00/00/00
1510.00       C*                                                                                               00/00/00
1511.00       C                   MOVEA     '00'          *IN(26)                        SFLCLR                00/00/00
1512.00       C                   MOVE      *ON           *IN29                                                00/00/00
1513.00       C                   WRITE     C01                                                                00/00/00
1514.00       C                   WRITE     R01                                                                00/00/00
1515.00       C*                                                                                               00/00/00
1516.00       C                   MOVE      *OFF          *IN27                                                00/00/00
1517.00       C                   MOVE      *ON           *IN28                                                00/00/00
1518.00       C*                                                                                               00/00/00
1519.00       C                   MOVE      *BLANKS       SCNA01                                               00/00/00
1520.00       C                   MOVE      *BLANKS       HLDA01                                               00/00/00
1521.00       C*                                                                                               00/00/00
1522.00       C*                                                                                               00/00/00
1523.00       C*                                                                                               00/00/00
1524.00       C                   Z-ADD     0             C1VEND                                               00/00/00
1525.00       C                   Z-ADD     0             C1SUFF                                               00/00/00
1526.00       C                   Z-ADD     0             C1DATE                                               00/00/00
1527.00       C*                                                                                               00/00/00
1528.00       C                   Z-ADD     0             C1PONO                                               00/00/00
1529.00       C                   Z-ADD     0             C1PRDT                                               00/00/00
1530.00       C                   Z-ADD     0             C1LINO                                               00/00/00
1531.00       C*                                                                                               00/00/00
1532.00       C*                                                                                               00/00/00
1533.00       C                   Z-ADD     0             H1VEND                                               00/00/00
1534.00       C                   Z-ADD     0             H1SUFF                                               00/00/00
1535.00       C                   Z-ADD     0             H1DATE                                               00/00/00
1536.00       C*                                                                                               00/00/00
1537.00       C                   Z-ADD     0             H1PONO                                               00/00/00
1538.00       C                   Z-ADD     0             H1PRDT                                               00/00/00
1539.00       C*                                                                                               00/00/00
1540.00       C                   MOVE      *OFF          FLGC01                                               00/00/00
1541.00       C*                                                                                               00/00/00
1542.00       C*                                                                                               00/00/00
1543.00       C                   ENDSR                                                                        00/00/00
1544.00       C*                                                                                               00/00/00
1545.00        ************************* GETTIM ******************************                                 00/00/00
1546.00        *   SUBROUTINE TO GET CURRENT DATE AND TIME                   *                                 00/00/00
1547.00        ************************* GETTIM ******************************                                 00/00/00
1548.00        *                                                                                               00/00/00
1549.00       C     GETTIM        BEGSR                                                                        00/00/00
1550.00       C*                                                                                               00/00/00
1551.00       C*                                                                                               00/00/00
1552.00       C                   TIME                    TIMDAT                                               00/00/00
1553.00       C                   MOVE      TDAT          CVTMDY                                               00/00/00
1554.00       C                   EXSR      CVTM2Y                                                             00/00/00
1555.00       C                   MOVE      CVTYMD        WKCDAT            7 0                                00/00/00
1556.00       C*                                                                                               00/00/00
1557.00       C*                                                                                               00/00/00
1558.00       C                   ENDSR                                                                        00/00/00
1559.00        /EJECT                                                                                          00/00/00
1560.00        ************************* LABPRT ******************************                                 00/00/00
1561.00        *   CREATE AND PRINT CIGARETTE LABELS FOR A PO                *                                 00/00/00
1562.00        ************************* LABPRT ******************************                                 00/00/00
1563.00        *                                                                                               00/00/00
1564.00       C     LABPRT        BEGSR                                                                        00/00/00
1565.00       C*                                                                                               00/00/00
1566.00       C*                                                                                               00/00/00
1567.00       C                   MOVE      ' '           WKCANC                                               00/00/00
1568.00       C                   Z-ADD     0             Y                                                    00/00/00
1569.00       C*                                                                                               00/00/00
1570.00       C*                                                                                               00/00/00
1571.00       C* CONVERT ARRIVAL DATE INTO MDY                                                                 00/00/00
1572.00       C                   MOVE      PMARDT        CVTYMD                         LAST SEEN DT          00/00/00
1573.00       C                   MOVE      CVTYY1        CVTYY2                          AND ADD DT           00/00/00
1574.00       C                   Z-ADD     CVTMDY        PRARDT            6 0           IN FILE AS           00/00/00
1575.00       C*                                                                                               00/00/00
1576.00       C*                                                                                               00/00/00
1577.00       C                   SELECT                                                                       00/00/00
1578.00       C     PMFLGL        WHENEQ    'Y'                                                                00/00/00
1579.00       C                   MOVE      'NEW'         CIGTYP            3                                  00/00/00
1580.00       C                   OTHER                                                                        00/00/00
1581.00       C                   MOVE      '   '         CIGTYP                                               00/00/00
1582.00       C                   ENDSL                                                                        00/00/00
1583.00       C*                                                                                               00/00/00
1584.00       C*                                                                                               00/00/00
1585.00       C     CIGTYP        IFNE      '   '                                                              00/00/00
1586.00       C     PMRUNT        ANDEQ     0                                                                  00/00/00
1587.00       C*                                                                                               00/00/00
1588.00       C*                                                                                               00/00/00
1589.00       C     VMKEY1        CHAIN     INVMSTR                            91                              00/00/00
1590.00       C*                                                                                               00/00/00
1591.00       C     *IN91         IFEQ      *OFF                                                               00/00/00
1592.00       C                   MOVEL     VMNAME        PRNAME                                               00/00/00
1593.00       C                   ELSE                                                                         00/00/00
1594.00       C                   MOVEL     *BLANKS       PRNAME                                               00/00/00
1595.00       C                   ENDIF                                                                        00/00/00
1596.00       C*                                                                                               00/00/00
1597.00       C*                                                                                               00/00/00
1598.00       C*                                                                                               00/00/00
1599.00       C                   MOVE      *ON           FULDST            1                                  00/00/00
1600.00       C                   MOVE      *OFF          RECVD             1                                  00/00/00
1601.00       C*                                                                                               00/00/00
1602.00       C                   Z-ADD     0             WKSEQ#            5 0                                00/00/00
1603.00       C                   Z-ADD     0             IX                5 0                                00/00/00
1604.00       C                   Z-ADD     0             JX                5 0                                00/00/00
1605.00       C                   MOVEA     *BLANKS       AR                                                   00/00/00
1606.00       C                   MOVEA     *BLANKS       A1                                                   00/00/00
1607.00       C*                                                                                               00/00/00
1608.00       C     PDKEY1        CHAIN     INPDTRR36                          91                              04/09/04
1609.00       C*                                                                                               00/00/00
1610.00       C     *IN91         DOWEQ     *OFF                                                               00/00/00
1611.00       C     FULDST        ANDEQ     *ON                                                                00/00/00
1612.00       C     RECVD         ANDEQ     *OFF                                                               00/00/00
1613.00       C*                                                                                               00/00/00
1614.00       C     PDQORD        IFNE      PDQOHS                                                             00/00/00
1615.00       C                   MOVE      *OFF          FULDST                                               00/00/00
1616.00       C                   ENDIF                                                                        00/00/00
1617.00       C     PDVREC        IFNE      0                                                                  00/00/00
1618.00       C                   MOVE      *ON           RECVD                                                00/00/00
1619.00       C                   ENDIF                                                                        00/00/00
1620.00       C*                                                                                               00/00/00
1621.00       C                   EXSR      LABITM                                                             00/00/00
1622.00       C*                                                                                               00/00/00
1623.00       C     PDKEY1        READE     INPDTRR36                              91                          04/09/04
1624.00       C                   ENDDO                                                  *IN91 DOWEQ           00/00/00
1625.00       C*                                                                                               00/00/00
1626.00       C*                                                                                               00/00/00
1627.00       C     FULDST        IFEQ      *ON                                                                00/00/00
1628.00       C     RECVD         ANDEQ     *OFF                                                               00/00/00
1629.00       C     IX            ANDNE     0                                                                  00/00/00
1630.00       C*                                                                                               00/00/00
1631.00       C                   EXSR      LABDEL                                                             00/00/00
1632.00       C*                                                                                               00/00/00
1633.00       C                   EXSR      LABWRT                                                             00/00/00
1634.00       C                   ENDIF                                                                        00/00/00
1635.00       C*                                                                                               00/00/00
1636.00       C*                                                                                               00/00/00
1637.00       C                   ENDIF                                                  CIGTYP...             00/00/00
1638.00       C*                                                                                               00/00/00
1639.00       C*                                                                                               00/00/00
1640.00       C*                                                                                               00/00/00
1641.00       C                   ENDSR                                                                        00/00/00
1642.00       C*                                                                                               00/00/00
1643.00       C************************** LABITM ******************************                                00/00/00
1644.00       C*   CREATE AND PRINT CIGARETTE LABELS FOR PO ITEM              *                                00/00/00
1645.00       C************************** LABITM ******************************                                00/00/00
1646.00       C*                                                                                               00/00/00
1647.00       C     LABITM        BEGSR                                                                        00/00/00
1648.00       C*                                                                                               00/00/00
1649.00       C*                                                                                               00/00/00
1650.00       C*                                                                                               00/00/00
1651.00       C     PIKEY         CHAIN     INPITM30                           96                              04/09/04
1652.00       C*                                                                                               00/00/00
1653.00       C     *IN96         IFEQ      *OFF                                                               00/00/00
1654.00       C     PIMPK         IFEQ      60                                                                 00/00/00
1655.00       C     PIVBUQ        ANDEQ     60                                                                 00/00/00
1656.00       C                   MOVE      *ON           SPLIT             1                                  00/00/00
1657.00       C     PIVBUQ        DIV       2             WKSELU                                               00/00/00
1658.00       C                   ELSE                                                                         00/00/00
1659.00       C                   MOVE      *OFF          SPLIT                                                00/00/00
1660.00       C                   Z-ADD     PIVBUQ        WKSELU                                               00/00/00
1661.00       C                   ENDIF                                                                        00/00/00
1662.00       C                   ENDIF                                                                        00/00/00
1663.00       C*                                                                                               00/00/00
1664.00       C*                                                                                               00/00/00
1665.00       C*                                                                                               00/00/00
1666.00       C                   SELECT                                                                       00/00/00
1667.00       C*                                                                                               00/00/00
1668.00       C*                                                                                               00/00/00
1669.00       C*                                                                                               00/00/00
1670.00       C     CIGTYP        WHENEQ    'NEW'                                                              00/00/00
1671.00       C*                                                                                               00/00/00
1672.00       C*                                                                                               00/00/00
1673.00       C*                                                                                               00/00/00
1674.00       C     PMWHS5        CHAIN     INWCTLR                            92                              04/09/04
1675.00       C     *IN92         IFEQ      *ON                                                                00/00/00
1676.00       C                   MOVE      *BLANKS       WCREGN                                               00/00/00
1677.00       C                   ENDIF                                                                        00/00/00
1678.00       C*                                                                                               00/00/00
1679.00       C                   EVAL      DSDESC = getItemDescription1(WKCMPY: PDITEM)                       10/12/20
1680.00       C*                                                                                               00/00/00
1681.00       C                   MOVE      PDFLD2        DSBUPC                                               00/00/00
1682.00       C                   MOVE      PDITEM        DSITEM                                               00/00/00
1683.00       C*                                                                                               00/00/00
1684.00       C*                                                                                               00/00/00
1685.00       C                   OTHER                                                  SHOULD NEVER          00/00/00
1686.00       C*                                                     HAPPEN                                    00/00/00
1687.00       C                   MOVE      *BLANKS       DSDESC                                               00/00/00
1688.00       C                   MOVE      *BLANKS       DSBUPC                                               00/00/00
1689.00       C                   MOVE      *BLANKS       DSITEM                                               00/00/00
1690.00       C*                                                                                               00/00/00
1691.00       C*                                                                                               00/00/00
1692.00       C                   ENDSL                                                                        00/00/00
1693.00       C*                                                                                               00/00/00
1694.00       C*                                                                                               00/00/00
1695.00       C*                                                                                               00/00/00
1696.00       C*                                                                                               00/00/00
1697.00       C*                                                                                               00/00/00
1698.00       C*                                                                                               00/00/00
1699.00       C                   Z-ADD     0             X                 3 0                                00/00/00
1700.00       C*                                                                                               00/00/00
1701.00       C*                                                                                               00/00/00
1702.00       C     PSKEY         CHAIN     INPDSHR                            92                              00/00/00
1703.00       C*                                                                                               00/00/00
1704.00       C     *IN92         DOWEQ     '0'                                                                00/00/00
1705.00       C*                                                                                               00/00/00
1706.00       C     PSQORD        SUB       PSDSNO        TOSHIP                                               00/00/00
1707.00       C*                                                                                               00/00/00
1708.00       C*                                                                                               00/00/00
1709.00       C* START PS TOSHIP LOOP                                                                          00/00/00
1710.00       C*                                                                                               00/00/00
1711.00       C*                                                                                               00/00/00
1712.00       C     TOSHIP        DOWGT     0                                                                  00/00/00
1713.00       C*                                                                                               00/00/00
1714.00       C*                                                                                               00/00/00
1715.00       C*  CALCULATE SELL UNITS ON PALLET                                                               00/00/00
1716.00       C     TOSHIP        IFGE      WKSELU                                                             00/00/00
1717.00       C                   Z-ADD     WKSELU        WKQSHP                                               00/00/00
1718.00       C                   ELSE                                                   SHOULD NEVER          00/00/00
1719.00       C                   Z-ADD     TOSHIP        WKQSHP                          HAPPEN               00/00/00
1720.00       C                   END                                                                          00/00/00
1721.00       C                   SUB       WKQSHP        TOSHIP                                               00/00/00
1722.00       C*                                                                                               00/00/00
1723.00       C*                                                                                               00/00/00
1724.00       C                   ADD       1             X                                                    00/00/00
1725.00       C*                                                                                               00/00/00
1726.00       C     SPLIT         IFEQ      *ON                                                                00/00/00
1727.00       C*                                                                                               00/00/00
1728.00       C                   SELECT                                                                       00/00/00
1729.00       C     X             WHENEQ    1                                                                  00/00/00
1730.00       C                   MOVE      PSWHS5        DSWHSE                                               04/09/04
1731.00       C                   MOVE      PSVBUQ        DSQSHP                                               00/00/00
1732.00       C                   ADD       1             WKSEQ#                                               00/00/00
1733.00       C                   MOVE      WKSEQ#        DSSEQ#                                               00/00/00
1734.00       C                   MOVE      'A'           DSPART                                               00/00/00
1735.00       C     WKSEQ#        ADD       1             WKASEQ            5 0                                00/00/00
1736.00       C                   MOVE      WKASEQ        DSASEQ                                               00/00/00
1737.00       C*                                                                                               00/00/00
1738.00       C     X             WHENEQ    2                                                                  00/00/00
1739.00       C                   MOVE      PSWHS5        DSWHSE                                               04/09/04
1740.00       C                   MOVE      PSVBUQ        DSQSHP                                               00/00/00
1741.00       C                   ADD       1             WKSEQ#                                               00/00/00
1742.00       C                   MOVE      WKSEQ#        DSSEQ#                                               00/00/00
1743.00       C                   MOVE      'B'           DSPART                                               00/00/00
1744.00       C     WKSEQ#        SUB       1             WKASEQ            5 0                                00/00/00
1745.00       C                   MOVE      WKASEQ        DSASEQ                                               00/00/00
1746.00       C*                                                                                               00/00/00
1747.00       C                   Z-ADD     0             X                                                    00/00/00
1748.00       C                   ENDSL                                                                        00/00/00
1749.00       C*                                                                                               00/00/00
1750.00       C                   ADD       1             IX                                                   00/00/00
1751.00       C*                                                                                               00/00/00
1752.00       C*                                                                                               00/00/00
1753.00       C* IF MORE THAN 9999 LABELS FOR THE PO, LOAD LABELS 10000 THRU                                   00/00/00
1754.00       C* 19998 INTO SECOND ARRAY A1                                                                    00/00/00
1755.00       C*                                                                                               00/00/00
1756.00       C     IX            IFLE      9999                                                               00/00/00
1757.00       C                   MOVEL     DSDATA        AR(IX)                                               00/00/00
1758.00       C                   ELSE                                                                         00/00/00
1759.00       C     IX            SUB       9999          JX                                                   00/00/00
1760.00       C                   MOVEL     DSDATA        A1(JX)                                               00/00/00
1761.00       C                   ENDIF                                                                        00/00/00
1762.00       C*                                                                                               00/00/00
1763.00       C                   ELSE                                                                         00/00/00
1764.00       C*                                                                                               00/00/00
1765.00       C                   MOVE      PSWHS5        DSWHSE                                               04/09/04
1766.00       C                   MOVE      PSVBUQ        DSQSHP                                               00/00/00
1767.00       C                   ADD       1             WKSEQ#                                               00/00/00
1768.00       C                   MOVE      WKSEQ#        DSSEQ#                                               00/00/00
1769.00       C                   MOVE      ' '           DSPART                                               00/00/00
1770.00       C                   MOVE      *BLANKS       DSASEQ                                               00/00/00
1771.00       C                   ADD       1             IX                                                   00/00/00
1772.00       C*                                                                                               00/00/00
1773.00       C*                                                                                               00/00/00
1774.00       C* IF MORE THAN 9999 LABELS FOR THE PO, LOAD LABELS 10000 THRU                                   00/00/00
1775.00       C* 19998 INTO SECOND ARRAY A1                                                                    00/00/00
1776.00       C*                                                                                               00/00/00
1777.00       C     IX            IFLE      9999                                                               00/00/00
1778.00       C                   MOVEL     DSDATA        AR(IX)                                               00/00/00
1779.00       C                   ELSE                                                                         00/00/00
1780.00       C     IX            SUB       9999          JX                                                   00/00/00
1781.00       C                   MOVEL     DSDATA        A1(JX)                                               00/00/00
1782.00       C                   ENDIF                                                                        00/00/00
1783.00       C*                                                                                               00/00/00
1784.00       C*                                                                                               00/00/00
1785.00       C                   Z-ADD     0             X                                                    00/00/00
1786.00       C*                                                                                               00/00/00
1787.00       C                   ENDIF                                                  SPLIT=ON              00/00/00
1788.00       C*                                                                                               00/00/00
1789.00       C*                                                                                               00/00/00
1790.00       C                   ENDDO                                                                        00/00/00
1791.00       C*                                                                                               00/00/00
1792.00       C* END PS TOSHIP LOOP                                                                            00/00/00
1793.00       C*                                                                                               00/00/00
1794.00       C*                                                                                               00/00/00
1795.00       C*                                                                                               00/00/00
1796.00       C     PSKEY         READE     INPDSHR                                92                          00/00/00
1797.00       C                   ENDDO                                                  *IN92                 00/00/00
1798.00       C*                                                                                               00/00/00
1799.00       C*                                                                                               00/00/00
1800.00       C     SPLIT         IFEQ      *ON                                          SHOULD NEVER          00/00/00
1801.00       C     X             ANDEQ     1                                             HAPPEN               00/00/00
1802.00       C                   ADD       1             IX                                                   00/00/00
1803.00       C*                                                                                               00/00/00
1804.00       C                   Z-ADD     0             X                                                    00/00/00
1805.00       C                   ENDIF                                                                        00/00/00
1806.00       C*                                                                                               00/00/00
1807.00       C*                                                                                               00/00/00
1808.00       C                   ENDSR                                                                        00/00/00
1809.00       C*                                                                                               00/00/00
1810.00       C*                                                                                               00/00/00
1811.00       C************************** LABWRT ******************************                                00/00/00
1812.00       C*   PRINT LABEL AND WRITE INCGLBP RECORD                       *                                00/00/00
1813.00       C************************** LABWRT ******************************                                00/00/00
1814.00       C*                                                                                               00/00/00
1815.00       C     LABWRT        BEGSR                                                                        00/00/00
1816.00       C*                                                                                               00/00/00
1817.00       C*                                                                                               00/00/00
1818.00       C     1             DO        IX            Z                 5 0                                00/00/00
1819.00       C*                                                                                               00/00/00
1820.00       C*                                                                                               00/00/00
1821.00       C* IF MORE THAN 9999 LABELS FOR THE PO, RETRIEVE LABELS 10000                                    00/00/00
1822.00       C* THROUGH 19998 FROM SECOND ARRAY A1                                                            00/00/00
1823.00       C*                                                                                               00/00/00
1824.00       C     Z             IFLE      9999                                                               00/00/00
1825.00       C                   MOVEL     AR(Z)         DSDATA                                               00/00/00
1826.00       C                   ELSE                                                                         00/00/00
1827.00       C     Z             SUB       9999          JX                                                   00/00/00
1828.00       C                   MOVEL     A1(JX)        DSDATA                                               00/00/00
1829.00       C                   ENDIF                                                                        00/00/00
1830.00       C*                                                                                               00/00/00
1831.00       C*                                                                                               00/00/00
1832.00       C*                                                                                               00/00/00
1833.00       C                   EVAL      LBAWH5 = PMWHS5                                                    05/02/21
1834.00       C                   Z-ADD     PMPONO        LBPONO                                               00/00/00
1835.00       C                   MOVE      DSWHSE        LBWHS5                                               04/09/04
1836.00       C                   MOVE      DSSEQ#        LBSEQ#                                               00/00/00
1837.00       C                   MOVE      DSBUPC        LBBUPC                                               00/00/00
1838.00       C                   MOVE      DSITEM        LBITEM                                               00/00/00
1839.00       C                   MOVE      DSQSHP        LBQSHP                                               00/00/00
1840.00       C                   MOVEL     DSDESC        LBDESC                                               00/00/00
1841.00       C                   MOVE      DSPART        LBPART                                               00/00/00
1842.00       C                   MOVE      DSASEQ        LBASEQ                                               00/00/00
1843.00       C                   Z-ADD     0             LBLINO                                               00/00/00
1844.00       C                   MOVE      *BLANKS       LBSTAT                                               00/00/00
1845.00       C                   MOVE      *BLANKS       LBFLG1                                               00/00/00
1846.00       C                   MOVE      WKCANC        LBFLG2                                               00/00/00
1847.00       C                   MOVE      *BLANKS       LBFLG3                                               00/00/00
1848.00       C                   MOVE      *BLANKS       LBFLG4                                               00/00/00
1849.00       C*                                                                                               00/00/00
1850.00       C*                                                                                               00/00/00
1851.00       C                   TIME                    TIMDAT                                               00/00/00
1852.00       C*                                                                                               00/00/00
1853.00       C                   MOVE      TDAT          CVTMDY                                               00/00/00
1854.00       C                   EXSR      CVTM2Y                                                             00/00/00
1855.00       C                   MOVE      CVTYMD        LBADDT                         CYMD                  00/00/00
1856.00       C*                                                                                               00/00/00
1857.00       C*                                                                                               00/00/00
1858.00       C                   Z-ADD     LBAWH5        LBAWHS                                               04/09/04
1859.00       C                   Z-ADD     LBWHS5        LBWHSE                                               04/09/04
1860.00       C                   WRITE     INCGLBR                                                            00/00/00
1861.00       C*                                                                                               00/00/00
1862.00       C*                                                                                               00/00/00
1863.00       C*                                                                                               00/00/00
1864.00       C* FORMAT PRINT FIELDS FOR BOTH "30" AND "60" LABELS                                             00/00/00
1865.00       C*                                                                                               00/00/00
1866.00       C                   MOVEL     LBDESC        PRDESC                                               00/00/00
1867.00       C                   MOVE      *BLANKS       PRBUPC                                               00/00/00
1868.00       C*                                                                                               00/00/00
1869.00       C                   SELECT                                                                       00/00/00
1870.00       C     LBBUPC        WHENGE    1                                                                  00/00/00
1871.00       C     LBBUPC        ANDLE     9                                                                  00/00/00
1872.00       C                   Z-ADD     7             S                 3 0                                00/00/00
1873.00       C                   Z-ADD     1             L                 3 0                                00/00/00
1874.00       C     LBBUPC        WHENGE    11                                                                 00/00/00
1875.00       C     LBBUPC        ANDLE     99                                                                 00/00/00
1876.00       C                   Z-ADD     6             S                 3 0                                00/00/00
1877.00       C                   Z-ADD     2             L                 3 0                                00/00/00
1878.00       C     LBBUPC        WHENGE    101                                                                00/00/00
1879.00       C     LBBUPC        ANDLE     999                                                                00/00/00
1880.00       C                   Z-ADD     5             S                 3 0                                00/00/00
1881.00       C                   Z-ADD     3             L                 3 0                                00/00/00
1882.00       C     LBBUPC        WHENGE    1001                                                               00/00/00
1883.00       C     LBBUPC        ANDLE     9999                                                               00/00/00
1884.00       C                   Z-ADD     4             S                 3 0                                00/00/00
1885.00       C                   Z-ADD     4             L                 3 0                                00/00/00
1886.00       C     LBBUPC        WHENGE    10001                                                              00/00/00
1887.00       C     LBBUPC        ANDLE     99999                                                              00/00/00
1888.00       C                   Z-ADD     3             S                 3 0                                00/00/00
1889.00       C                   Z-ADD     5             L                 3 0                                00/00/00
1890.00       C     LBBUPC        WHENGE    100001                                                             00/00/00
1891.00       C     LBBUPC        ANDLE     999999                                                             00/00/00
1892.00       C                   Z-ADD     2             S                 3 0                                00/00/00
1893.00       C                   Z-ADD     6             L                 3 0                                00/00/00
1894.00       C     LBBUPC        WHENGE    1000001                                                            00/00/00
1895.00       C     LBBUPC        ANDLE     9999999                                                            00/00/00
1896.00       C                   Z-ADD     1             S                 3 0                                00/00/00
1897.00       C                   Z-ADD     7             L                 3 0                                00/00/00
1898.00       C                   OTHER                                                                        00/00/00
1899.00       C                   Z-ADD     1             S                 3 0                                00/00/00
1900.00       C                   Z-ADD     7             L                 3 0                                00/00/00
1901.00       C                   ENDSL                                                                        00/00/00
1902.00       C*                                                                                               00/00/00
1903.00       C                   MOVE      LBBUPC        WKBUPC            7                                  00/00/00
1904.00       C     L             SUBST     WKBUPC:S      PRBUPC            7                                  00/00/00
1905.00       C*                                                                                               00/00/00
1906.00       C*                                                                                               00/00/00
1907.00       C*                                                                                               00/00/00
1908.00       C*                                                                                               00/00/00
1909.00       C* PRINT CIGARETTE LABEL FOR 30 CARTON CASE OR 60 CARTON CASE                                    00/00/00
1910.00       C*                                                                                               00/00/00
1911.00       C                   SELECT                                                                       00/00/00
1912.00       C*                                                                                               00/00/00
1913.00       C     LBPART        WHENEQ    ' '                                                                00/00/00
1914.00       C     LBASEQ        ANDEQ     0                                                                  00/00/00
1915.00       C                   Z-ADD     LBPONO        WKPON1                                               00/00/00
1916.00       C                   Z-ADD     LBSEQ#        WKSEQ1                                               00/00/00
1917.00       C                   EVAL      PRWHS1 = LBWHS5                                                    05/02/21
1918.00       C                   CALLP     printlbl30                                                         24/05/16
1919.00       C                   EVAL      *INOG = *OFF                                                       05/04/13
1920.00       C                   Z-ADD     0             WKPON1                                               00/00/00
1921.00       C                   Z-ADD     0             WKSEQ1                                               00/00/00
1922.00       C                   Z-ADD     0             WKPON2                                               00/00/00
1923.00       C                   Z-ADD     0             WKSEQ2                                               00/00/00
1924.00       C                   Z-ADD     0             PRWHS1                                               00/00/00
1925.00       C                   Z-ADD     0             PRWHS2                                               00/00/00
1926.00       C*                                                                                               00/00/00
1927.00       C     LBPART        WHENEQ    'A'                                                                00/00/00
1928.00       C                   Z-ADD     LBPONO        WKPON1                                               00/00/00
1929.00       C                   Z-ADD     LBSEQ#        WKSEQ1                                               00/00/00
1930.00       C                   EVAL      PRWHS1 = LBWHS5                                                    05/02/21
1931.00       C*                                                                                               00/00/00
1932.00       C     LBPART        WHENEQ    'B'                                                                00/00/00
1933.00       C                   Z-ADD     LBPONO        WKPON2                                               00/00/00
1934.00       C                   Z-ADD     LBSEQ#        WKSEQ2                                               00/00/00
1935.00       C                   EVAL      PRWHS2 = LBWHS5                                                    05/02/21
1936.00       C                   CALLP     printlbl60                                                         24/05/16
1937.00       C                   EVAL      *INOG = *OFF                                                       05/04/13
1938.00       C                   Z-ADD     0             WKPON1                                               05/04/13
1939.00       C                   Z-ADD     0             WKSEQ1                                               00/00/00
1940.00       C                   Z-ADD     0             WKPON2                                               00/00/00
1941.00       C                   Z-ADD     0             WKSEQ2                                               00/00/00
1942.00       C                   Z-ADD     0             PRWHS1                                               00/00/00
1943.00       C                   Z-ADD     0             PRWHS2                                               00/00/00
1944.00       C*                                                                                               00/00/00
1945.00       C                   ENDSL                                                  30 OR 60              00/00/00
1946.00       C*                                                                                               00/00/00
1947.00       C*                                                                                               00/00/00
1948.00       C                   ENDDO                                                                        00/00/00
1949.00       C*                                                                                               00/00/00
1950.00       C*                                                                                               00/00/00
1951.00       C                   ENDSR                                                                        00/00/00
1952.00       C*                                                                                               00/00/00
1953.00       C*                                                                                               00/00/00
1954.00       C************************** RSETPM ******************************                                00/00/00
1955.00       C*   RESET TO CURRENT INPMSTP RECORD IN LOADING S01             *                                00/00/00
1956.00       C************************** RSETPM ******************************                                00/00/00
1957.00       C*                                                                                               00/00/00
1958.00       C     RSETPM        BEGSR                                                                        00/00/00
1959.00       C*                                                                                               00/00/00
1960.00       C*                                                                                               00/00/00
1961.00       C* Reset keys of currently read but not displayed PO record, which                               00/00/00
1962.00       C* will be the first to be displayed when roll is pressed.                                       00/00/00
1963.00       C*                                                                                               00/00/00
1964.00       C*                                                                                               00/00/00
1965.00       C                   SELECT                                                                       00/00/00
1966.00       C*                                                                                               00/00/00
1967.00       C     WKKEYS        WHENEQ    'DV'                                                               00/00/00
1968.00       C     PMKEY5        CHAIN     INPMSTR                            68                              00/00/00
1969.00       C*                                                                                               00/00/00
1970.00       C     WKKEYS        WHENEQ    'PO'                                                               00/00/00
1971.00       C     PMKEY6        CHAIN     INPMSTR32                          68                              04/09/04
1972.00       C*                                                                                               00/00/00
1973.00       C     WKKEYS        WHENEQ    'DT'                                                               00/00/00
1974.00       C     PMKEY7        CHAIN     INPMSTR35                          68                              04/09/04
1975.00       C*                                                                                               00/00/00
1976.00       C                   ENDSL                                                                        00/00/00
1977.00       C*                                                                                               00/00/00
1978.00       C*                                                                                               00/00/00
1979.00       C                   ENDSR                                                                        00/00/00
1980.00       C*                                                                                               00/00/00
1981.00       C*                                                                                               00/00/00
1982.00       C************************** EDTPRT ******************************                                00/00/00
1983.00       C*   EDIT PRINTER CODE                                          *                                00/00/00
1984.00       C************************** EDTPRT ******************************                                00/00/00
1985.00       C*                                                                                               00/00/00
1986.00       C     EDTPRT        BEGSR                                                                        00/00/00
1987.00       C*                                                                                               00/00/00
1988.00       C*                                                                                               00/00/00
1989.00       C***********************                                                                         00/00/00
1990.00       C* VALIDATION  OF HEADER                                                                         00/00/00
1991.00       C***********************                                                                         00/00/00
1992.00       C*                                                                                               00/00/00
1993.00       C* EDIT PRINTER OPION                                                                            00/00/00
1994.00       C                   SETOFF                                       30                              00/00/00
1995.00       C*                                                                                               00/00/00
1996.00       C                   MOVE      C1PNTR        WKPNTR                                               10/01/25
1997.00       C                                                                                                10/01/25
1998.00       C                   CALL      'INR2427'                                                          10/01/25
1999.00       C                   PARM                    WKPNTR                                               10/01/25
2000.00       C                   PARM                    WKOUTQ                                               10/01/25
2001.00       C                                                                                                10/01/25
2002.00       C                   MOVE      WKOUTQ        W2OUTQ                                               10/01/25
2003.00       C                                                                                                10/01/25
2004.00       C                   CALL      'QCMDEXC'                            44      CKOBJ CMD             00/00/00
2005.00       C                   PARM                    CMD2                                                 00/00/00
2006.00       C                   PARM                    LENGTH                                               00/00/00
2007.00       C*                                                                                               00/00/00
2008.00       C     *IN44         IFEQ      '1'                                                                00/00/00
2009.00       C                   MOVE      'Y'           ERROR                                                00/00/00
2010.00       C                   ELSE                                                                         00/00/00
2011.00       C*                                                                                               00/00/00
2012.00       C     C1PNTR        IFNE      SVPNTR                                                             00/00/00
2013.00       C                   MOVE      C1PNTR        SVPNTR                                               00/00/00
2014.00       C                   CALLP     closeZebraPrinterFile()                                            24/05/16
2015.00       C*                  CALL      'QCMDEXC'                                    OVRPRTF CMD           24/05/16
2016.00       C*                  PARM                    CMD1                                                 24/05/16
2017.00       C*                  PARM                    LENGTH                                               24/05/16
2018.00       C*                                                                                               00/00/00
2019.00       C                   CALLP     openZebraPrinterFile( WkOutq :                                     24/05/16
2020.00       C                                   'INP1031' : 'INR1031' )                                      24/05/16
2021.00       C                   ENDIF                                                                        00/00/00
2022.00       C*                                                                                               00/00/00
2023.00       C                   ENDIF                                                                        00/00/00
2024.00       C*                                                                                               00/00/00
2025.00       C                   ENDSR                                                                        00/00/00
2026.00       C*                                                                                               00/00/00
2027.00       C*                                                                                               00/00/00
2028.00       C************************** LABCNC ******************************                                00/00/00
2029.00       C*   FLAG ALL CIGARETTE LABELS FOR A PO WITH STATUS OF "D"      *                                00/00/00
2030.00       C************************** LABCNC ******************************                                00/00/00
2031.00       C*                                                                                               00/00/00
2032.00       C     LABCNC        BEGSR                                                                        00/00/00
2033.00       C*                                                                                               00/00/00
2034.00       C*                                                                                               00/00/00
2035.00       C* Cancel label records for the PO (to get this far, they all                                    00/00/00
2036.00       C* should be status of " ".                                                                      00/00/00
2037.00       C*                                                                                               00/00/00
2038.00       C*                                                                                               00/00/00
2039.00       C                   MOVE      ' '           WKSTAT                                               00/00/00
2040.00       C*                                                                                               00/00/00
2041.00       C                   EXSR      GETTIM                                                             00/00/00
2042.00       C     LBKEY1        CHAIN     INCGLBR32                          71                              04/09/04
2043.00       C     *IN71         DOWEQ     *OFF                                                               00/00/00
2044.00       C                   MOVE      'D'           LBSTAT                                               00/00/00
2045.00       C                   Z-ADD     WKCDAT        LBSTDT                                               00/00/00
2046.00       C                   MOVE      ' '           LBFLG2                                               00/00/00
2047.00       C                   EXCEPT    UPDLB2                                                             00/00/00
2048.00       C     LBKEY1        READE     INCGLBR32                              71                          04/09/04
2049.00       C                   ENDDO                                                                        00/00/00
2050.00       C*                                                                                               00/00/00
2051.00       C*                                                                                               00/00/00
2052.00       C                   ENDSR                                                                        00/00/00
2053.00       C*                                                                                               00/00/00
2054.00       C************************** LABDEL ******************************                                00/00/00
2055.00       C*   DELETE PREV. CANCELLED LABELS ON SUBSEQUENT LABEL PRINT    *                                00/00/00
2056.00       C************************** LABDEL ******************************                                00/00/00
2057.00       C*                                                                                               00/00/00
2058.00       C     LABDEL        BEGSR                                                                        00/00/00
2059.00       C*                                                                                               00/00/00
2060.00       C*                                                                                               00/00/00
2061.00       C* Delete label records for the PO (to get this far, they all                                    00/00/00
2062.00       C* should be status of "D".                                                                      00/00/00
2063.00       C*                                                                                               00/00/00
2064.00       C                   MOVE      ' '           WKCANC                                               00/00/00
2065.00       C                   MOVE      'D'           WKSTAT                                               00/00/00
2066.00       C*                                                                                               00/00/00
2067.00       C     LBKEY1        CHAIN     INCGLBR32                          71                              04/09/04
2068.00       C     *IN71         DOWEQ     *OFF                                                               00/00/00
2069.00       C*                                                                                               00/00/00
2070.00       C     WKCANC        IFEQ      ' '                                                                00/00/00
2071.00       C                   MOVE      'Y'           WKCANC                                               00/00/00
2072.00       C                   ENDIF                                                                        00/00/00
2073.00       C*                                                                                               00/00/00
2074.00       C                   DELETE    INCGLBR32                                                          04/09/04
2075.00       C     LBKEY1        READE     INCGLBR32                              71                          04/09/04
2076.00       C                   ENDDO                                                                        00/00/00
2077.00       C*                                                                                               00/00/00
2078.00       C*                                                                                               00/00/00
2079.00       C*                                                                                               00/00/00
2080.00       C                   ENDSR                                                                        00/00/00
2081.00       C*                                                                                               00/00/00
2082.00       C*                                                                                               00/00/00
2083.00       C************************** FINIT ********************************                               00/00/00
2084.00       C* INITIALIZE WORK FIELDS & OPEN FILES                           *                               00/00/00
2085.00       C************************** FINIT ********************************                               00/00/00
2086.00       C*                                                                                               00/00/00
2087.00       C     FINIT         BEGSR                                                                        00/00/00
2088.00       C* Changed to have UC file opens to improve performance, files                                   00/00/00
2089.00       C* stay open until job ends.                                                                     00/00/00
2090.00       C     OPNMN         IFEQ      ' '                                                                00/00/00
2091.00       C                   OPEN      INVMST30                                                           04/09/04
2092.00       C                   OPEN      INVMST07                                                           00/00/00
2093.00       C                   OPEN      INPMST30                                                           04/09/04
2094.00       C                   OPEN      INPMST32                                                           04/09/04
2095.00       C                   OPEN      INPMST35                                                           04/09/04
2096.00       C                   OPEN      INWCTL30                                                           04/09/04
2097.00       C                   OPEN      INCGLBP                                                            00/00/00
2098.00       C                   OPEN      INCGLB31                                                           04/09/04
2099.00       C                   OPEN      INCGLB32                                                           04/09/04
2100.00       C                   OPEN      INPDTR30                                                           04/09/04
2101.00       C                   OPEN      INPDTR36                                                           04/09/04
2102.00       C                   OPEN      INPDSH39                                                           04/09/04
2103.00       C                   OPEN      INPITM30                                                           04/09/04
2104.00       C                   MOVE      'Y'           OPNMN             1                                  00/00/00
2105.00       C                   END                                                                          00/00/00
2106.00       C                   OPEN      IND1031                                                            00/00/00
2107.00       C* Reset *ARRAY & *DS                                                                            00/00/00
2108.00       C                   Z-ADD     0             CVTMDY                                               00/00/00
2109.00       C                   Z-ADD     0             CVTYMD                                               00/00/00
2110.00       C                   Z-ADD     0             TIMDAT                                               00/00/00
2111.00       C*                                                                                               00/00/00
2112.00       C* Clear PRTF Record Formats                                                                     00/00/00
2113.00       C* All Program-Defined variables need to be reset.                                               00/00/00
2114.00       C*                                                                                               00/00/00
2115.00       C*                                                                                               00/00/00
2116.00       C                   EVAL      WKZERO = *ZEROS                                                    04/09/04
2117.00       C                   MOVE      'P'           WKFPT             1                                  00/00/00
2118.00       C                   Z-ADD     0             WKDSDT                                               00/00/00
2119.00       C*                                                                                               00/00/00
2120.00       C                   Z-ADD     0             Y                 3 0                                00/00/00
2121.00       C*                                                                                               00/00/00
2122.00       C                   Z-ADD     0             PRBRC1                                               00/00/00
2123.00       C                   Z-ADD     0             PRBRC2                                               00/00/00
2124.00       C*                                                                                               00/00/00
2125.00       C                   MOVE      *ALL'-'       PRDASH           29                                  00/00/00
2126.00       C*                                                                                               00/00/00
2127.00       C                   MOVEA     *ZEROS        *IN(01)                                              00/00/00
2128.00       C                   MOVE      *BLANKS       ERROR             1                                  00/00/00
2129.00       C                   Z-ADD     38            LENGTH           15 5                                00/00/00
2130.00       C                   Z-ADD     0             SVRR1             3 0                                00/00/00
2131.00       C                   Z-ADD     0             RRX               2 0                                00/00/00
2132.00       C                   Z-ADD     0             RR1               3 0                                00/00/00
2133.00       C                   Z-ADD     0             WKCDAT                                               00/00/00
2134.00       C                   MOVE      *ALL'0'       WKOF10           10                                  00/00/00
2135.00       C                   MOVE      *OFF          FLGC01            1                                  00/00/00
2136.00       C                   MOVE      *OFF          *IN04                                                00/00/00
2137.00       C                   MOVE      *ZEROS        SCNN01                                               00/00/00
2138.00       C                   MOVE      *ZEROS        HLDN01                                               00/00/00
2139.00       C                   MOVE      *BLANKS       SCNA01                                               00/00/00
2140.00       C                   MOVE      *BLANKS       HLDA01                                               00/00/00
2141.00       C*                                                                                               00/00/00
2142.00       C*                                                                                               00/00/00
2143.00       C                   Z-ADD     11            C1DEPT            2 0                                00/00/00
2144.00       C                   Z-ADD     11            WKDEPT                                               00/00/00
2145.00       C*                                                                                               00/00/00
2146.00       C                   MOVE      ' '           H1STAT            1                                  00/00/00
2147.00       C*                                                                                               00/00/00
2148.00       C                   MOVE      *BLANKS       C1PNTR                                               00/00/00
2149.00       C                   MOVE      '*'           SVPNTR                                               00/00/00
2150.00       C*                                                                                               00/00/00
2151.00       C* Clear DSPF Record Formats                                                                     00/00/00
2152.00       C                   MOVEL     C1OPTN        SVOPTN                                               00/00/00
2153.00       C                   CLEAR                   C01                                                  00/00/00
2154.00       C                   MOVEL     SVOPTN        C1OPTN                                               00/00/00
2155.00       C                   SETON                                        28                              00/00/00
2156.00       C*                                                                                               00/00/00
2157.00       C* Set UTR100 variables                                                                          00/00/00
2158.00       C                   Z-ADD     0             PDAYS                          Date Adjustment       00/00/00
2159.00       C                   Z-ADD     0             PBEGDT                         Date In               00/00/00
2160.00       C                   Z-ADD     0             PENDDT                         Date Out              00/00/00
2161.00       C                   MOVE      ' '           PERROR                         Date Format Errflag   00/00/00
2162.00       C                   MOVE      '*MDY '       PFMTIN                         Date In Format        00/00/00
2163.00       C                   MOVE      '*MDY '       PFMTOT                         Date Out Format       00/00/00
2164.00       C*                                                                                               00/00/00
2165.00       C                   ENDSR                                                                        00/00/00
2166.00       C*                                                                                               00/00/00
2167.00       C*****************************************************************                               00/00/00
2168.00       C*======================== CVTM2Y================================                                00/00/00
2169.00       C     CVTM2Y        BEGSR                                                                        00/00/00
2170.00        *                                                                                               00/00/00
2171.00       C                   MOVE      CVTYY2        CVTYY1                         SHIFT YEAR            00/00/00
2172.00       C     CVTMDY        IFEQ      0                                            DATE=000000           00/00/00
2173.00       C                   MOVE      '0'           CVTCC                                                00/00/00
2174.00       C                   ELSE                                                                         00/00/00
2175.00       C     CVTMDY        IFEQ      999999                                       DATE=999999           00/00/00
2176.00       C                   MOVE      '9'           CVTCC                                                00/00/00
2177.00       C                   ELSE                                                                         00/00/00
2178.00       C     CVTYY1        IFLT      '40'                                            2000-2039          00/00/00
2179.00       C                   MOVE      '1'           CVTCC                          21ST CENTURY          00/00/00
2180.00       C                   ELSE                                                      1940-1999          00/00/00
2181.00       C                   MOVE      '0'           CVTCC                          20TH CENTURY          00/00/00
2182.00       C                   ENDIF                                                                        00/00/00
2183.00       C                   ENDIF                                                                        00/00/00
2184.00       C                   ENDIF                                                                        00/00/00
2185.00       C                   ENDSR                                                                        00/00/00
2186.00       C*===============================================================                                00/00/00
2187.00       C****************************************************************                                00/00/00
2188.00       OINCGLBR32 E            UPDLB2                                                                   04/09/04
2189.00       O                       LBSTAT                                                                   00/00/00
2190.00       O                       LBSTDT                                                                   00/00/00
2191.00       O                       LBFLG2                                                                   00/00/00
2192.00        *****************************************************************                               24/05/16
2193.00        * THIRTY-CARTON CIGARETTE LABEL SPECIFICATIONS                  *                               24/05/16
2194.00        * Procedure to print LBL30 using UTS008                         *                               24/05/16
2195.00        *****************************************************************                               24/05/16
2196.00       P printlbl30...                                                                                  24/05/16
2197.00       P                 B                                                                              24/05/16
2198.00       D                 PI                                                                             24/05/16
2199.00                                                                                                        24/05/16
2200.00       D titlePO         S              2A   inz('PO')                                                  24/05/16
2201.00       D titleSEQ        S              3A   inz('SEQ')                                                 24/05/16
2202.00                                                                                                        24/05/16
2203.00        /free                                                                                           24/05/16
2204.00                                                                                                        24/05/16
2205.00                                                                                                        24/05/16
2206.00         // UTS008 procedure to create the START element in ZPL                                         24/05/16
2207.00         startZebraLabel();                                                                             24/05/16
2208.00                                                                                                        24/05/16
2209.00         // UTS008 procedure to set the units of measure                                                24/05/16
2210.00         setZebraUnitsOfMeasure( UNIT_OF_MEASURE_DOTS);                                                 24/05/16
2211.00                                                                                                        24/05/16
2212.00         // UTS008 procedure to set orientation                                                         24/05/16
2213.00         setZebraFieldOrientation( ORIENTATION_NORMAL);                                                 24/05/16
2214.00                                                                                                        24/05/16
2215.00         // UTS008 procedure to set the font, height and width for PRBUPC                               24/05/16
2216.00         setZebraDefaultFont( ZEBRA_FONT_P :205 :110);                                                  24/05/16
2217.00         printZebraTextTypeset(35:1020:%char(PRBUPC));                                                  24/05/16
2218.00                                                                                                        24/05/16
2219.00         // UTS008 procedure to set the font, height and width for Warehouse                            24/05/16
2220.00         setZebraDefaultFont( ZEBRA_FONT_P :130 :110);                                                  24/05/16
2221.00         printZebraText(460: 920: %editc(PRWHS1:'7'));                                                  24/05/16
2222.00                                                                                                        24/05/16
2223.00         // UTS008 procedure to set the font, height and width for Item Details                         24/05/16
2224.00         setZebraDefaultFont( ZEBRA_FONT_P :60  : 55);                                                  24/05/16
2225.00         printZebraTextTypeset(40 :1120:%char(PRNAME));                                                 24/05/16
2226.00         printZebraTextTypeset(40 :1180:%char(PRDESC));                                                 24/05/16
2227.00                                                                                                        24/05/16
2228.00         // UTS008 procedure to set the font, height and width for PO &                                 24/05/16
2229.00         // Seq Details                                                                                 24/05/16
2230.00         setZebraDefaultFont( ZEBRA_FONT_P :60  : 40);                                                  24/05/16
2231.00         printZebraTextTypeset(40 :1460:%char(titlePO));                                                24/05/16
2232.00         printZebraTextTypeset(120:1460:%char(PRPONO));                                                 24/05/16
2233.00         printZebraTextTypeset(380:1460:%char(titleSEQ));                                               24/05/16
2234.00         printZebraTextTypeset(510:1460:%editc(WKSEQ1:'X'));                                            26/10/21
2235.00                                                                                                        24/05/16
2236.00        // UTS008 procedure to print the barcode                                                        24/05/16
2237.00         setZebraBarCodeDefaults( 4 : *omit : 350);                                                     24/05/16
2238.00         printZebraBarCodeC128( 40 :                         //x-position                               24/05/16
2239.00                                1230 :                       //y-position                               24/05/16
2240.00                                %editc(PRBRC1:'X'):          //data                                     25/04/03
2241.00                                ORIENTATION_NORMAL:          //orientation                              24/05/16
2242.00                                150   :                      //height                                   24/05/16
2243.00                                'N':                         //print interpretation                     24/05/16
2244.00                                *omit :                      //interpretation above                     24/05/16
2245.00                                'N' :                        //print check digit                        24/05/16
2246.00                                'A');                        //print mode                               24/05/16
2247.00                                                                                                        24/05/16
2248.00         // UTS008 procedure to create the END element in ZPL                                           24/05/16
2249.00         endZebraLabel();                                                                               24/05/16
2250.00                                                                                                        24/05/16
2251.00         return;                                                                                        24/05/16
2252.00                                                                                                        24/05/16
2253.00        /end-free                                                                                       24/05/16
2254.00                                                                                                        24/05/16
2255.00       P  printlbl30     E                                                                              24/05/16
2256.00                                                                                                        24/05/16
2257.00        *****************************************************************                               24/05/16
2258.00        * SIXTY-CARTON CIGARETTE LABEL SPECIFICATIONS                   *                               24/05/16
2259.00        * Procedure to print LBL60 using UTS008                         *                               24/05/16
2260.00        *****************************************************************                               24/05/16
2261.00       P printlbl60...                                                                                  24/05/16
2262.00       P                 B                                                                              24/05/16
2263.00       D                 PI                                                                             24/05/16
2264.00                                                                                                        24/05/16
2265.00       D titlePO         S              2A   inz('PO')                                                  24/05/16
2266.00       D titleSEQ        S              3A   inz('SEQ')                                                 24/05/16
2267.00                                                                                                        24/05/16
2268.00        /free                                                                                           24/05/16
2269.00                                                                                                        24/05/16
2270.00         // UTS008 procedure to create the START element in ZPL                                         24/05/16
2271.00         startZebraLabel();                                                                             24/05/16
2272.00                                                                                                        24/05/16
2273.00         // UTS008 procedure to set the units of measure                                                24/05/16
2274.00         setZebraUnitsOfMeasure( UNIT_OF_MEASURE_DOTS);                                                 24/05/16
2275.00                                                                                                        24/05/16
2276.00         // UTS008 procedure to set orientation                                                         24/05/16
2277.00         setZebraFieldOrientation( ORIENTATION_NORMAL);                                                 24/05/16
2278.00                                                                                                        24/05/16
2279.00         // UTS008 procedure to set the font, height and width for PRBUPC                               24/05/16
2280.00         setZebraDefaultFont( ZEBRA_FONT_P :205 :110);                                                  24/05/16
2281.00         printZebraTextTypeset(35:1020:%char(PRBUPC));                                                  24/05/16
2282.00                                                                                                        24/05/16
2283.00         // UTS008 procedure to set the font, height and width for Warehouse                            24/05/16
2284.00         setZebraDefaultFont( ZEBRA_FONT_P :130 :110);                                                  24/05/16
2285.00         printZebraText(460: 920: %editc(PRWHS1:'7'));                                                  24/05/16
2286.00                                                                                                        24/05/16
2287.00         // UTS008 procedure to set the font, height and width for Item Details                         24/05/16
2288.00         setZebraDefaultFont( ZEBRA_FONT_P :60  : 55);                                                  24/05/16
2289.00         printZebraTextTypeset(40 :1120:%char(PRNAME));                                                 24/05/16
2290.00         printZebraTextTypeset(40 :1180:%char(PRDESC));                                                 24/05/16
2291.00                                                                                                        24/05/16
2292.00         // UTS008 procedure to set the font, height and width for PO &                                 24/05/16
2293.00         // Seq Details                                                                                 24/05/16
2294.00         setZebraDefaultFont( ZEBRA_FONT_P :60  : 40);                                                  24/05/16
2295.00         printZebraTextTypeset(40 :1460:%char(titlePO));                                                24/05/16
2296.00         printZebraTextTypeset(120:1460:%char(PRPONO));                                                 24/05/16
2297.00         printZebraTextTypeset(380:1460:%char(titleSEQ));                                               24/05/16
2298.00         printZebraTextTypeset(510:1460:%editc(WKSEQ1:'X'));                                            26/10/21
2299.00                                                                                                        24/05/16
2300.00        // UTS008 procedure to print the barcode                                                        24/05/16
2301.00         setZebraBarCodeDefaults( 4 : *omit : 350);                                                     24/05/16
2302.00         printZebraBarCodeC128( 40 :                         //x-position                               24/05/16
2303.00                                1230 :                       //y-position                               24/05/16
2304.00                                %editc(PRBRC1:'X'):          //data                                     25/04/03
2305.00                                ORIENTATION_NORMAL:          //orientation                              24/05/16
2306.00                                150   :                      //height                                   24/05/16
2307.00                                'N':                         //print interpretation                     24/05/16
2308.00                                *omit :                      //interpretation above                     24/05/16
2309.00                                'N' :                        //print check digit                        24/05/16
2310.00                                'A');                        //print mode                               24/05/16
2311.00                                                                                                        24/05/16
2312.00          // The division for the second portion of the label                                           24/05/16
2313.00          // UTS008 procedure to set orientation                                                        24/05/16
2314.00          setZebraFieldOrientation( ORIENTATION_ROTATE_180);                                            24/05/16
2315.00                                                                                                        24/05/16
2316.00          setZebraDefaultFont( ZEBRA_FONT_R : 20 : 20);                                                 24/05/16
2317.00          printZebraTextTypeset(700: 750 : %char(PRDASH));                                              24/05/16
2318.00                                                                                                        24/05/16
2319.00         // UTS008 procedure to set the font, height and width for PRBUPC                               24/05/16
2320.00         setZebraDefaultFont( ZEBRA_FONT_P :205 :110);                                                  24/05/16
2321.00         printZebraTextTypeset(670:475:%char(PRBUPC));                                                  24/05/16
2322.00                                                                                                        24/05/16
2323.00         // UTS008 procedure to set the font, height and width for Warehouse                            24/05/16
2324.00         setZebraDefaultFont( ZEBRA_FONT_P :130 :110);                                                  24/05/16
2325.00         printZebraTextTypeset(250:475:%editc(PRWHS2:'7'));                                             24/05/16
2326.00                                                                                                        24/05/16
2327.00         // UTS008 procedure to set the font, height and width for Item Details                         24/05/16
2328.00         setZebraDefaultFont( ZEBRA_FONT_P :60  : 55);                                                  24/05/16
2329.00         printZebraTextTypeset(670 :390:%char(PRNAME));                                                 24/05/16
2330.00         printZebraTextTypeset(670 :330:%char(PRDESC));                                                 24/05/16
2331.00                                                                                                        24/05/16
2332.00         // UTS008 procedure to set the font, height and width for PO &                                 24/05/16
2333.00         // Seq Details                                                                                 24/05/16
2334.00         setZebraDefaultFont( ZEBRA_FONT_P :60  : 40);                                                  24/05/16
2335.00         printZebraTextTypeset(665:  50:%char(titlePO));                                                24/05/16
2336.00         printZebraTextTypeset(590:  50:%char(PRPONO));                                                 24/05/16
2337.00         printZebraTextTypeset(330:  50:%char(titleSEQ));                                               24/05/16
2338.00         printZebraTextTypeset(200:  50:%editc(WKSEQ2:'X'));                                            26/10/21
2339.00                                                                                                        24/05/16
2340.00        // UTS008 procedure to print the barcode                                                        24/05/16
2341.00         setZebraBarCodeDefaults( 4 : *omit : 350);                                                     24/05/16
2342.00         printZebraBarCodeC128( 200:                         //x-position                               24/05/16
2343.00                                150:                         //y-position                               24/05/16
2344.00                                %editc(PRBRC2:'X'):          //data                                     25/04/03
2345.00                                ORIENTATION_ROTATE_180 :     //orientation                              24/05/16
2346.00                                150   :                      //height                                   24/05/16
2347.00                                'N':                         //print interpretation                     24/05/16
2348.00                                *omit :                      //interpretation above                     24/05/16
2349.00                                'N':                         //print check digit                        24/05/16
2350.00                                'A');                        //print mode                               24/05/16
2351.00                                                                                                        24/05/16
2352.00         // UTS008 procedure to create the END element in ZPL                                           24/05/16
2353.00         endZebraLabel();                                                                               24/05/16
2354.00                                                                                                        24/05/16
2355.00         return;                                                                                        24/05/16
2356.00                                                                                                        24/05/16
2357.00        /end-free                                                                                       24/05/16
2358.00                                                                                                        24/05/16
2359.00       P  printlbl60     E                                                                              24/05/16
2360.00                                                                                                        24/05/16
2361.00        *****************************************************************                               24/05/16
2362.00                                                                                                        24/05/16
2363.00       O*                                                                                               00/00/00
2364.00  **CTDATA CMD2                                                                                         00/00/00
2365.00  CHKOBJ OBJ(XXXXXXXXXX) OBJTYPE(*OUTQ)                                                                 00/00/00
