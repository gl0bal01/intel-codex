---
title: "Sample Crypto Challenge: Caesar Cipher with Twist"
description: "CTF writeup: a Caesar cipher whose shift grows by one per word. Brute-force every shift, read the diagonal of readable words, confirm shift = 3 + word index, decode the flag."
tags:
  - ctf-writeup
  - crypto
  - caesar-cipher
  - variable-shift
  - pattern-recognition
updated: 2026-11-07
---

# 🔐 Sample Crypto Challenge: Caesar Cipher with Twist

**Challenge**: Ancient Messages
**Category**: Cryptography
**Points**: 150
**Event**: Beginner CTF 2024
**Team**: Team Example
**Author**: CTF Guide
**Date**: 2024-01-15

---

## 🎯 Challenge Summary

**TL;DR**: Every word is an ordinary Caesar word, but the shift grows by one per word (word 0 → 3, word 1 → 4, …). Brute-forcing a single shift decodes one word per line; reading those lines diagonally gives the rule, and the rule decodes the flag.

### Challenge Description
```text
The ancient Romans had a sophisticated way of encoding their messages.
We intercepted this message, but it seems more complex than a simple Caesar cipher.
Can you decode it?

File: ancient_message.txt
Hint: The Romans were quite systematic in their approach.
```

### Files & Services
- `ancient_message.txt` - Encrypted text file (one line)

---

## 🔍 Analysis

### Initial Reconnaissance
Let's examine the provided file:

```bash
cat ancient_message.txt
file ancient_message.txt
wc -w ancient_message.txt
```

```text
Kdlo Geiwev. Ymj rkmout thyjolz vwzbp jc nkgx. Jzfc rxms vf tzou{gvwth_ufckg_pm_cbs_soqv_kcfr}
ancient_message.txt: ASCII text
12 ancient_message.txt
```

### Key Observations
1. **Text format**: mixed case, with `.`, `{`, `_` and `}` left in place — a letter-only substitution that preserves case.
2. **Structure**: 12 words, two short "sentences" ending in `.`, then a token shaped like `xxxx{...}` — almost certainly the encrypted `flag{...}`.
3. **Hint**: "systematic" suggests a rule, not a random key.

The snippets below run in order in one Python 3 session (REPL or a single script) started in the directory that holds `ancient_message.txt`. First, a quick frequency count:

```python
from collections import Counter

ciphertext = open("ancient_message.txt").read().strip()
letters = [c.lower() for c in ciphertext if c.isalpha()]
print(len(letters), "letters")
print(Counter(letters).most_common(6))
```

```text
74 letters
[('k', 5), ('o', 5), ('v', 5), ('c', 5), ('g', 4), ('m', 4)]
```

74 letters is too little text for frequency analysis to pin down a key, and four letters tie for first place — no single letter stands out as the shifted `e`. A flat profile like this hints that more than one shift is in play, but it is not proof. A Caesar cipher has only 25 useful keys, so brute force costs nothing.

---

## 💡 Solution Approach

### Method 1: Brute-force a single shift (dead end, but it holds the answer)

**Step 1 — try all 25 shifts.**

```python
def caesar(text, k):
    """Shift ASCII letters by k (negative k decrypts); keep case and non-letters."""
    out = []
    for c in text:
        if c.isascii() and c.isalpha():
            base = ord("A") if c.isupper() else ord("a")
            out.append(chr((ord(c) - base + k) % 26 + base))
        else:
            out.append(c)
    return "".join(out)

for k in range(1, 26):
    print(f"{k:2}: {caesar(ciphertext, -k)}")
```

```text
 1: Jckn Fdhvdu. Xli qjlnts sgxinky uvyao ib mjfw. Iyeb qwlr ue synt{fuvsg_tebjf_ol_bar_rnpu_jbeq}
 2: Ibjm Ecguct. Wkh pikmsr rfwhmjx tuxzn ha liev. Hxda pvkq td rxms{eturf_sdaie_nk_azq_qmot_iadp}
 3: Hail Dbftbs. Vjg ohjlrq qevgliw stwym gz khdu. Gwcz oujp sc qwlr{dstqe_rczhd_mj_zyp_plns_hzco}
 4: Gzhk Caesar. Uif ngikqp pdufkhv rsvxl fy jgct. Fvby ntio rb pvkq{crspd_qbygc_li_yxo_okmr_gybn}
 5: Fygj Bzdrzq. The mfhjpo octejgu qruwk ex ifbs. Euax mshn qa oujp{bqroc_paxfb_kh_xwn_njlq_fxam}
 6: Exfi Aycqyp. Sgd legion nbsdift pqtvj dw hear. Dtzw lrgm pz ntio{apqnb_ozwea_jg_wvm_mikp_ewzl}
 7: Dweh Zxbpxo. Rfc kdfhnm marches opsui cv gdzq. Csyv kqfl oy mshn{zopma_nyvdz_if_vul_lhjo_dvyk}
 8: Cvdg Ywaown. Qeb jcegml lzqbgdr north bu fcyp. Brxu jpek nx lrgm{ynolz_mxucy_he_utk_kgin_cuxj}
 9: Bucf Xvznvm. Pda ibdflk kypafcq mnqsg at ebxo. Aqwt iodj mw kqfl{xmnky_lwtbx_gd_tsj_jfhm_btwi}
10: Atbe Wuymul. Ocz hacekj jxozebp lmprf zs dawn. Zpvs hnci lv jpek{wlmjx_kvsaw_fc_sri_iegl_asvh}
11: Zsad Vtxltk. Nby gzbdji iwnydao kloqe yr czvm. Your gmbh ku iodj{vkliw_jurzv_eb_rqh_hdfk_zrug}
12: Yrzc Uswksj. Max fyacih hvmxczn jknpd xq byul. Xntq flag jt hnci{ujkhv_itqyu_da_qpg_gcej_yqtf}
13: Xqyb Trvjri. Lzw exzbhg gulwbym ijmoc wp axtk. Wmsp ekzf is gmbh{tijgu_hspxt_cz_pof_fbdi_xpse}
14: Wpxa Squiqh. Kyv dwyagf ftkvaxl hilnb vo zwsj. Vlro djye hr flag{shift_grows_by_one_each_word}
15: Vowz Rpthpg. Jxu cvxzfe esjuzwk ghkma un yvri. Ukqn cixd gq ekzf{rghes_fqnvr_ax_nmd_dzbg_vnqc}
16: Unvy Qosgof. Iwt buwyed drityvj fgjlz tm xuqh. Tjpm bhwc fp djye{qfgdr_epmuq_zw_mlc_cyaf_umpb}
17: Tmux Pnrfne. Hvs atvxdc cqhsxui efiky sl wtpg. Siol agvb eo cixd{pefcq_doltp_yv_lkb_bxze_tloa}
18: Sltw Omqemd. Gur zsuwcb bpgrwth dehjx rk vsof. Rhnk zfua dn bhwc{odebp_cnkso_xu_kja_awyd_sknz}
19: Rksv Nlpdlc. Ftq yrtvba aofqvsg cdgiw qj urne. Qgmj yetz cm agvb{ncdao_bmjrn_wt_jiz_zvxc_rjmy}
20: Qjru Mkockb. Esp xqsuaz znepurf bcfhv pi tqmd. Pfli xdsy bl zfua{mbczn_aliqm_vs_ihy_yuwb_qilx}
21: Piqt Ljnbja. Dro wprtzy ymdotqe abegu oh splc. Oekh wcrx ak yetz{labym_zkhpl_ur_hgx_xtva_phkw}
22: Ohps Kimaiz. Cqn voqsyx xlcnspd zadft ng rokb. Ndjg vbqw zj xdsy{kzaxl_yjgok_tq_gfw_wsuz_ogjv}
23: Ngor Jhlzhy. Bpm unprxw wkbmroc yzces mf qnja. Mcif uapv yi wcrx{jyzwk_xifnj_sp_fev_vrty_nfiu}
24: Mfnq Igkygx. Aol tmoqwv vjalqnb xybdr le pmiz. Lbhe tzou xh vbqw{ixyvj_whemi_ro_edu_uqsx_meht}
25: Lemp Hfjxfw. Znk slnpvu uizkpma wxacq kd olhy. Kagd synt wg uapv{hwxui_vgdlh_qn_dct_tprw_ldgs}
```

**Step 2 — analyse the partial success.** No line reads as English from start to finish, so this is not a plain Caesar cipher. Shift 3, the classic Caesar key, decodes only the first word:

```text
 3: Hail Dbftbs. Vjg ohjlrq qevgliw stwym gz khdu. Gwcz oujp sc qwlr{dstqe_rczhd_mj_zyp_plns_hzco}
```

Read the table diagonally instead of line by line. Each word becomes readable on exactly one line, and that line moves down by one for each word:

| Word index | Shift | Readable word |
|---|---|---|
| 0 | 3 | `Hail` |
| 1 | 4 | `Caesar.` |
| 2 | 5 | `The` |
| 3 | 6 | `legion` |
| 4 | 7 | `marches` |
| … | … | … |
| 11 | 14 | `flag{shift_grows_by_one_each_word}` |

Shift 14 even exposes the whole flag token. That is expected: inside one word the cipher is still a plain Caesar shift, so brute force recovers every word on *some* line. The work left is to prove the rule rather than pick words out by eye.

**Step 3 — hypothesis: shift = 3 + word index (0-based).** Test it without hand-picking anything. For each ciphertext word, look for shifts that turn it into a common English function word and print `shift - index`:

```python
STOPWORDS = {"a", "an", "and", "are", "as", "at", "be", "by", "for", "from",
             "in", "is", "it", "of", "on", "or", "that", "the", "to", "was",
             "with", "you", "your"}

for i, word in enumerate(ciphertext.split()):
    for k in range(1, 26):
        guess = caesar(word, -k).strip(".").lower()
        if guess in STOPWORDS:
            print(f"word {i:2}  {word:<8} shift {k:2} -> {guess:<5} (shift - index = {k - i})")
```

```text
word  2  Ymj      shift  5 -> the   (shift - index = 3)
word  6  jc       shift  9 -> at    (shift - index = 3)
word  8  Jzfc     shift 11 -> your  (shift - index = 3)
word 10  vf       shift 13 -> is    (shift - index = 3)
```

Four independent words, no false positives, and the offset is 3 every time. A crib gives a fifth check: if `tzou` (word 11) stands for `flag`, every letter moved by 14 (`t`→`f`, `z`→`l`, `o`→`a`, `u`→`g`), and 14 = 3 + 11. The decoded flag text, "shift grows by one each word", states the same rule.

**Step 4 — decode the whole message** with the solver below.

---

## 🛠️ Technical Details

### Tools Used
- **Primary tools**: Python 3, standard library only (`collections.Counter`, `re`)
- **Secondary tools**: `file`, `wc` for reconnaissance

### Key Technical Concepts
- **Caesar cipher**: every letter moves by the same fixed shift.
- **Progressive (per-word) Caesar**: the shift changes with position, here `3 + word index`. Each word on its own is still a Caesar word, which is why per-shift brute force decodes one word per line.
- **Frequency analysis**: needs far more than 74 letters, and mixing several shifts flattens the letter profile.
- **Crib**: a known plaintext fragment (`flag`) reveals the shift for the word that contains it.

### Cipher Definition
```text
For word w (0-based index over whitespace-separated tokens) and each ASCII letter in it,
with A=0 ... Z=25 and the letter's case kept:

    encrypt:  c = (p + 3 + w) mod 26
    decrypt:  p = (c - 3 - w) mod 26

Non-letters ( . { } _ ) are copied unchanged. Words are separated by single spaces.
```

---

## 🎯 The Solution

### Final Exploit
`solve.py`:

```python
#!/usr/bin/env python3
"""Ancient Messages solver: word i (0-based, whitespace-separated) was shifted by 3 + i."""
import re
import sys


def caesar(text, k):
    """Shift ASCII letters by k (negative k decrypts); keep case and non-letters."""
    out = []
    for c in text:
        if c.isascii() and c.isalpha():
            base = ord("A") if c.isupper() else ord("a")
            out.append(chr((ord(c) - base + k) % 26 + base))
        else:
            out.append(c)
    return "".join(out)


def decode(ciphertext, start=3):
    plain = []
    for i, word in enumerate(ciphertext.split()):
        k = start + i
        plain.append(caesar(word, -k))
        print(f"word {i:2}  shift {k:2}  {word:<36} -> {plain[-1]}")
    return " ".join(plain)


if __name__ == "__main__":
    message = decode(open(sys.argv[1]).read())
    print(f"\nPlaintext: {message}")
    flag = re.search(r"flag\{[^}]+\}", message)
    print(f"Flag: {flag.group() if flag else 'not found'}")
```

### Execution Output
```bash
python3 solve.py ancient_message.txt
```

```text
word  0  shift  3  Kdlo                                 -> Hail
word  1  shift  4  Geiwev.                              -> Caesar.
word  2  shift  5  Ymj                                  -> The
word  3  shift  6  rkmout                               -> legion
word  4  shift  7  thyjolz                              -> marches
word  5  shift  8  vwzbp                                -> north
word  6  shift  9  jc                                   -> at
word  7  shift 10  nkgx.                                -> dawn.
word  8  shift 11  Jzfc                                 -> Your
word  9  shift 12  rxms                                 -> flag
word 10  shift 13  vf                                   -> is
word 11  shift 14  tzou{gvwth_ufckg_pm_cbs_soqv_kcfr}   -> flag{shift_grows_by_one_each_word}

Plaintext: Hail Caesar. The legion marches north at dawn. Your flag is flag{shift_grows_by_one_each_word}
Flag: flag{shift_grows_by_one_each_word}
```

---

## 🏁 Flag

```text
flag{shift_grows_by_one_each_word}
```

---

## 💭 Reflection

### What Went Well
- Brute-forcing all 25 shifts was cheap, and its output already held the full answer along a diagonal.
- The stopword scan confirmed the rule mechanically instead of by eye; the `flag` crib gave an independent check.

### Challenges Faced
- No single shift reads cleanly, which at first looks like "not a Caesar cipher at all".
- Frequency analysis was inconclusive on 74 letters.

### Learning Outcomes
- **Read brute-force output in two directions**: a variable shift shows up as readable fragments that move from line to line.
- **Confirm a hypothesis with a test**: a generic wordlist and a crib beat eyeballing.
- **Spot the flag format in the ciphertext**: `xxxx{...}` survives encryption and is a free crib.

### Generalisation
This is a progressive Caesar: the key is a stream of shifts (3, 4, 5, …), one per word, which makes it a polyalphabetic cipher — in effect a [Vigenère cipher](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) whose key stream comes from word positions instead of a keyword. The [Trithemius cipher](https://en.wikipedia.org/wiki/Tabula_recta#Trithemius_cipher) is the per-letter version of the same idea. Its weaknesses: the whole key is one starting shift, each word is still an individual Caesar word, and the shifts repeat every 26 words (word 26 would use shift 29 ≡ 3). For variants that step per letter or by a different amount, test `shift = a + b × position (mod 26)` for all 26 × 26 pairs of `a` and `b` — 676 candidates, still trivial to brute-force.

---

## 🔗 References

### Documentation
- [Caesar cipher](https://en.wikipedia.org/wiki/Caesar_cipher) - The fixed-shift foundation
- [Frequency analysis](https://en.wikipedia.org/wiki/Frequency_analysis) - Statistical cryptanalysis and its data requirements
- [Vigenère cipher](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) - The general polyalphabetic case
- [Tabula recta — Trithemius cipher](https://en.wikipedia.org/wiki/Tabula_recta#Trithemius_cipher) - Progressive shift per letter

### Further Reading
- [Practical Cryptography](http://practicalcryptography.com/) - Classical cipher implementations and cryptanalysis
- [CryptoHack](https://cryptohack.org/) - Crypto challenge platform

### In This Vault
- [[sop-cryptography-analysis|Cryptography Analysis SOP]]
- [[CTF_Cheat_Sheets|CTF Cheat Sheets]] - Caesar brute-force and ROT13 snippets
- [[Writeups-Index|Writeups Index]]

---

## 📚 Appendix

### How the Challenge Was Built
The ciphertext was generated with the same `caesar()` helper, using a positive shift to encrypt. Run it next to `solve.py` to reproduce `ancient_message.txt` byte for byte:

```python
from solve import caesar

PLAINTEXT = "Hail Caesar. The legion marches north at dawn. Your flag is flag{shift_grows_by_one_each_word}"
print(" ".join(caesar(w, 3 + i) for i, w in enumerate(PLAINTEXT.split())))
```

```text
Kdlo Geiwev. Ymj rkmout thyjolz vwzbp jc nkgx. Jzfc rxms vf tzou{gvwth_ufckg_pm_cbs_soqv_kcfr}
```

---

**Completion Time**: `45 minutes`
**Team Size**: `1 member`
**First Blood**: `NO`
**Published**: `2024-01-15`

---

**Last Updated:** 2026-11-07
