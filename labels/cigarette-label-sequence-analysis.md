# Cigarette label sequence analysis

Program: `INR1031Z` (Cigarette PO Inquiry, ZPL).
Label file: `INCGLBP`. Item pack file: `INPITM30`. Distribution file: `INPDSH39`. Purchase-order detail: `INPDTR36`.

This note records what the program does with a sequence number, and what the files showed for the two purchase orders that were traced.

## How a sequence is assigned

Option `P` builds every label for the purchase order before anything is sent to the printer.

1. The sequence counter `WKSEQ#` is set to 0 once for the purchase order. It is not restarted for each item.
2. Each item is read from `INPDTR36`. The program chains `INPITM30` with warehouse, department, vendor, suffix, purchase order, and item.
3. The sell unit `WKSELU` is taken from `PIVBUQ` on that item row.
   - When `PIMPK` and `PIVBUQ` are both 60, the pair flag is turned on and the sell unit is `PIVBUQ / 2` (30).
   - For every other pack, the pair flag is turned off and the sell unit is `PIVBUQ` itself.
4. Distribution rows are read from `INPDSH39` for type `P`, the item warehouse, the purchase order, the item, and distribution date 0. Each matching row is processed. The next row with the same five key values follows.
5. The quantity that becomes labels is `TOSHIP = PSQORD - PSDSNO`. The shipped column on the distribution row is not read. A row whose `PSDSNO` already equals `PSQORD` adds no tag.
6. The loop subtracts one sell unit at a time and adds 1 to `WKSEQ#` for each label. `PSVBUQ` is copied onto the tag as the printed quantity. It does not set the sell unit.
7. After every item has been built, `LABWRT` writes each slot to `INCGLBP` and then prints it.

A purchase order is not printed at all until every item is fully distributed (`PDQORD = PDQOHS` on `INPDTR36`) and no item has a received quantity (`PDVREC = 0`). Full distribution only opens the print. It does not make `PSDSNO` equal `PSQORD`. On the first print, `PSDSNO` is still 0 and the whole distribution line is labeled.

## Two ways a number fails to show

### The digits are sent, but not in the SEQ position

The running program places the sequence with a field origin at Y=1415:

```
^FO510,1415^FD141^FS
```

`SEQ` itself is typeset on the baseline at Y=1460. The value uses `%char`, so a stored `00141` is sent as `141`. The barcode is drawn at Y=1230 with height 150, and its data keeps the five sequence digits (`110220900141`).

The change in source typesets the value on the same baseline as `SEQ` and keeps the leading zeros (`%editc(WKSEQ1:'X')`). The spools captured for these purchase orders were produced by the program that still emits `^FO510,1415`.

### A number is stored and then not printed

This happens only when the pair flag is on. Halves alternate.

| Half | Part | What is stored | What is printed |
|---|---|---|---|
| Odd | `A` | This sequence, and the next number as its mate | Nothing yet. The sequence is held. |
| Even | `B` | This sequence, and the previous number as its mate | Both halves, on one 60-carton tag. |

When the item ends on an odd half, the last part `A` has no part `B`. The program adds one empty slot after it. That slot has no item, no UPC, no warehouse, and sequence 0. Printing the empty slot clears the sequence that was being held, so the real part `A` never reaches the printer.

`INCGLBP` still receives the part `A` row, because the row is written before the program decides whether to print. Option `X` reads those saved rows, so the reprint produces the real tag and the empty tag.

The empty slot is not added when the pair flag is off. A pack of 30 and a buy quantity of 30 turns the flag off. An odd count such as 17 does not withhold a tag on that path.

An odd count withholds the last tag of the item only when `PIMPK` and `PIVBUQ` are both 60. The withheld number is the last sequence of that item, not a number in the middle of the run.

If the `INPITM30` chain does not find the item, the pair flag and the sell unit are left at whatever the previous item set. A found row replaces both.

## Purchase order 1208255, location 179

Item 165011. One distribution row.

| Field | Value |
|---|---:|
| Ship-to `PSWHS5` | 25 |
| `PSQORD` | 3600 |
| `PSDSNO` | 3570 |
| `TOSHIP` | 30 |
| `PSVBUQ` | 30 |

`3600 - 3570 = 30`, so the line produces one label. The original spool was not that label. It was the empty slot:

| ZPL field | Value |
|---|---|
| UPC | `0000000` |
| Description | blank |
| Warehouse | blank |
| Vendor | `RJ REYNOLDS EFT` (kept from the purchase-order header) |
| PO | `001791208255` |
| SEQ | `0` at `^FO510,1415` |
| Barcode | `120825500000` |

Option `X` reprinted both saved rows.

| Reprint | UPC | Description | Warehouse | SEQ | Barcode |
|---|---|---|---|---:|---|
| First | 30594 | CAMEL BLUE BOX | 25 | 1 | `120825500001` |
| Second | 0000000 | blank | blank | 0 | `120825500000` |

Sequence 1 is the tag for the 30 units still to ship. Sequence 0 is the extra slot. The original print sent only the extra slot. The vendor and the purchase order are filled on both, because those come from the purchase-order header rather than from the label slot.

## Purchase order 1102209, location 179

Every item has `PIMPK` 30 and `PIVBUQ` 30, and `INPITM30` has the rows. The pair flag is off for each of them. The ending sequence on `INCGLBP` for each item is the last number that item stored.

| Item | Labels | Sequences |
|---|---:|---|
| 1038993 | 104 | 1–104 |
| 1039084 | 25 | 105–129 |
| 1039098 | 6 | 130–135 |
| 1039105 | 17 | 136–152 |
| 1115304 | 5 | 153–157 |

Item 1039105 is the reported gap, sequence 141.

| Field | Value |
|---|---:|
| `PSQORD` | 510 |
| `PSDSNO` | 0 |
| `TOSHIP` | 510 |
| Sell unit | 30 |
| Labels | 17 |

The item before it ends at 135, and `135 + 17 = 152`, which is the ending number on the file. The 17 stored numbers are 136 through 152. Sequence 141 is the 6th. The boundaries also meet: 104 then 105, 129 then 130, 135 then 136, 152 then 153.

Pass 6 stores item 1039105, part blank, mate 0, sequence 141, and `printlbl30` is called. The tag carries purchase order `001791102209`, sequence `141`, and barcode `110220900141`. Pass 5 sends 140 and pass 7 sends 142 with the same command.

If the pair flag had been on for this item, the withheld tag would be the 17th and last, sequence 152. Sequence 141 would be the second half of the pair with 140 and would still be printed. The ending number 152 is the count of a complete run, so 141 was not left out of the file.

## What to read on a saved label

| `INCGLBP` row | Meaning |
|---|---|
| `LBPART` blank, `LBASEQ` 0, `LBSEQ#` greater than 0 | Ordinary tag. It was written and printed. |
| `LBPART` `A`, `LBASEQ` equal to the next number, and no part `B` row for that mate on the same item | The half that was held. It is on the file and was not on the original print. |
| `LBSEQ#` 0, blank item, blank UPC | The empty slot printed in place of that held half. |
| `LBPART` `A` followed by `LBPART` `B` for the mate | The pair was completed and printed together. |

For location 179 and purchase order 1102209, the row for sequence 141 should be item 1039105, part blank, mate 0.
