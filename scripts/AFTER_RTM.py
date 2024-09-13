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
import importlib.util
import git

pj = os.path.join
pn = os.path.normpath

script_path = os.path.dirname(os.path.realpath(__file__))
main_path = pn(script_path+"/..")
config_path = pj(main_path, ".SFLB.config")

os.chdir(pn(main_path+"/.."))

git_repo = git.Repo(os.path.dirname(os.path.realpath(config_path)), search_parent_directories=True)

PAF_REPO = "FiltersHeroes/PolishAnnoyanceFilters.git"
if "CI" in os.environ:
    with git_repo.config_reader() as cr:
        url = cr.get_value('remote "origin"', 'url')
        if url.startswith('http'):
            git.Repo.clone_from(f"https://github.com/{PAF_REPO}", pn(pj(os.getcwd(), "PolishAnnoyanceFilters")))
        else:
            git.Repo.clone_from(f"git@github.com:{PAF_REPO}", pn(pj(os.getcwd(), "PolishAnnoyanceFilters")))

os.chdir(pn(main_path+"/.."))

PAF_path = pn(pj(os.getcwd(), "PolishAnnoyanceFilters"))
os.chdir(PAF_path)

SFLB_path = pn(main_path+"/../ScriptsPlayground/scripts/SFLB.py")
if "CI" in os.environ:
    SFLB_path = "/usr/bin/SFLB.py"
spec = importlib.util.spec_from_file_location(
    "SFLB", SFLB_path)
SFLB = importlib.util.module_from_spec(spec)
spec.loader.exec_module(SFLB)


FILTERLISTS = [pj(PAF_path, "PAF_supp.txt"), pj(PAF_path, "PPB.txt")]

SFLB.main(FILTERLISTS, "", "true")
SFLB.doItAgainIfNeed(FILTERLISTS)
SFLB.push(FILTERLISTS)
