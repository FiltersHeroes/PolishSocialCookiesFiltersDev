#!/usr/bin/env python3
# coding=utf-8
# pylint: disable=C0103
# pylint: disable=no-member
# pylint: disable=anomalous-backslash-in-string
# pylint: disable=missing-class-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=line-too-long
#
import os
import re
import shutil
import importlib.util
import filecmp
import git

pj = os.path.join
pn = os.path.normpath
script_path = os.path.dirname(os.path.realpath(__file__))
main_path = pn(script_path+"/..")
config_path = pj(main_path, ".SFLB.config")
backup_path = pj(main_path, "backup")

os.chdir(main_path)

if os.path.exists(backup_path):
    shutil.rmtree(backup_path)
os.mkdir(backup_path)

# Robimy kopię plików, by potem porównać z nowymi wersjami i zobaczyć, czy przydałaby się też aktualizacji list PFEI.
shutil.copy2(pn("./sections/adblock_social_list/popupy.txt"),
             pn(pj(backup_path, "popupy.txt")))
shutil.copy2(pn("./sections/adblock_social_list/popupy_ogolne.txt"),
             pn(pj(backup_path, "popupy_ogolne.txt")))
shutil.copy2(pn("./sections/adblock_social_list/widgety_kontaktowe.txt"),
             pn(pj(backup_path, "widgety_kontaktowe.txt")))

for file in os.listdir(pn("./sections/adblock_social_list/uBO_AG")):
    if re.match(r"^popupy", file):
        shutil.copy2(pn(pj("./sections/adblock_social_list/uBO_AG", file)),
                     pn(pj(backup_path, file)))


SFLB_path = pn(main_path+"/../ScriptsPlayground/scripts/SFLB.py")
if "CI" in os.environ:
    SFLB_path = "/usr/bin/SFLB.py"
spec = importlib.util.spec_from_file_location("SFLB", SFLB_path)
SFLB = importlib.util.module_from_spec(spec)
spec.loader.exec_module(SFLB)

SFLB.main([pn(pj(main_path, "cookies_filters/cookies_uB_AG.txt")),
           pn(pj(main_path, "cookies_filters/adblock_cookies.txt")),
           pn(pj(main_path, "adblock_social_filters/social_filters_uB_AG.txt")),
           pn(pj(main_path, "adblock_social_filters/adblock_social_filters/adblock_social_list.txt"))],
          "", "true")

# Aktualizujemy główne listy, jeżeli suplementy zostały zaktualizowane.
# Jako argument przekazujemy jedną dowolną listę, bo to tylko pomoc w odnalezieniu ściezki repo,
# a skrypt sam ustali, którą powinien zaktualizować.
SFLB.doItAgainIfNeed(
    [pn(pj(main_path, "cookies_filters/adblock_cookies.txt"))])

SFLB.push([pn(pj(main_path, "cookies_filters/adblock_cookies.txt"))])


popupy_mod = filecmp.cmp(
    pn("./sections/adblock_social_list/popupy.txt"), pn(pj(backup_path, "popupy.txt")))
popupy_ogolne_mod = filecmp.cmp(
    pn("./sections/adblock_social_list/popupy_ogolne.txt"), pn(pj(backup_path, "popupy_ogolne.txt")))
widgety_kontaktowe_mod = filecmp.cmp(
    pn("./sections/adblock_social_list/widgety_kontaktowe.txt"), pn(pj(backup_path, "widgety_kontaktowe.txt")))

PAF = ""
if popupy_mod or popupy_ogolne_mod or widgety_kontaktowe_mod:
    PAF = "true"

PAF_supp = ""
for file in os.listdir(pn("./sections/adblock_social_list/uBO_AG")):
    if re.match(r"^popupy", file):
        result = filecmp.cmp(pn(pj("./sections/adblock_social_list/uBO_AG", file)),
                             pn(pj(backup_path, file)))
        if result:
            PAF_supp = "true"

if PAF or PAF_supp:
    os.chdir(pn(main_path+".."))
    if "CI" in os.environ:
        git_repo = git.Repo(os.path.dirname(os.path.realpath(
            config_path)), search_parent_directories=True)
        with git_repo.config_reader() as cr:
            url = cr.get_value('remote "origin"', 'url')
            if url.startswith('http'):
                git.Repo.clone_from("https://github.com/PolishFiltersTeam/PolishAnnoyanceFilters.git", pj(
                    os.getcwd(), "PolishAnnoyanceFilters"))
            else:
                git.Repo.clone_from("git@github.com:PolishFiltersTeam/PolishAnnoyanceFilters.git", pj(
                    os.getcwd(), "PolishAnnoyanceFilters"))
    os.chdir(pn("./PolishAnnoyanceFilters"))

if PAF and not PAF_supp:
    SFLB.main([pn("./PPB.txt"),
               pn("./PAF_pop-ups.txt"),
               pn("./PAF_contact_feedback_widgets.txt")],
              "", "true")
elif PAF_supp:
    SFLB.main([pn("./PAF_pop-ups_supp.txt"),
               pn("./PPB.txt"),
               pn("./PAF_pop-ups.txt"),
               pn("./PAF_contact_feedback_widgets.txt")],
              "", "true")

if PAF or PAF_supp:
    SFLB.doItAgainIfNeed([pn("./PPB.txt")])
    SFLB.push([pn("./PPB.txt")])

if os.path.exists(backup_path):
    shutil.rmtree(backup_path)
