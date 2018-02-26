import os
import subprocess

months = {"jan": "01",
        "feb": "02",
        "mar": "03",
        "apr": "04",
        "may": "05",
        "jun": "06",
        "jul": "07",
        "aug": "08",
        "sep": "09",
        "oct": "10",
        "nov": "11",
        "dec": "12",
        }


def rename(oldname):
    for mon in months.keys():
        parts = oldname.split(mon)
        if len(parts) > 1:
            break
    else:
        raise ValueError("Doesn't match expected format")

    day = parts[0]
    if len(day) < 2:
        day = "0" + day

    year = parts[1].split(".")[0]

    return "meeting" + year + months[mon] + day + ".md"


for old_nm in os.listdir():
    try:
        nm = rename(old_nm)
        print(nm)
        subprocess.run(("git", "mv", old_nm, nm))
    except ValueError:
        next

