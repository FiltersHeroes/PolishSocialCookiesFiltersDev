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
import random
import urllib.parse
from tempfile import NamedTemporaryFile
from datetime import datetime
import git
import shutil
import importlib.util
from github import Auth
from github import Github
from github import GithubIntegration

pj = os.path.join
pn = os.path.normpath
script_path = os.path.dirname(os.path.realpath(__file__))
main_path = pn(script_path+"/..")
config_path = pj(main_path, ".SFLB.config")

os.chdir(pn(main_path+"/.."))

git_repo = git.Repo(os.path.dirname(os.path.realpath(
    config_path)), search_parent_directories=True)

FORKED_REPO = "PolishRoboDogHouse/polish-ads-filter.git"

SFLB_path = pn(main_path+"/../ScriptsPlayground/scripts/SFLB.py")
if "CI" in os.environ:
    SFLB_path = "/usr/bin/SFLB.py"
spec = importlib.util.spec_from_file_location(
    "SFLB", SFLB_path)
SFLB = importlib.util.module_from_spec(spec)
spec.loader.exec_module(SFLB)

if "CI" in os.environ and "git_repo" in locals():
    conf = SFLB.getValuesFromConf([config_path])
    with git_repo.config_writer() as cw:
        if hasattr(conf(), 'CIusername'):
            cw.set_value("user", "name", conf().CIusername).release()
        if hasattr(conf(), 'CIemail'):
            cw.set_value("user", "email", conf().CIemail).release()

if "CI" in os.environ:
    with git_repo.config_reader() as cr:
        url = cr.get_value('remote "origin"', 'url')
        if url.startswith('http'):
            git.Repo.clone_from(
                f"https://github.com/{FORKED_REPO}", pn(pj(os.getcwd(), "polish-ads-filter")), branch="RTM", single_branch=True)
        else:
            git.Repo.clone_from(
                f"git@github.com:{FORKED_REPO}", pn(pj(os.getcwd(), "polish-ads-filter")), branch="RTM", single_branch=True)

os.chdir(pn(main_path+"/.."))
forked_repo_path = pn(pj(os.getcwd(), "polish-ads-filter"))
shutil.copytree(pj(main_path, "sections"), pj(
    forked_repo_path, "sections"),  dirs_exist_ok=True)
shutil.copytree(pj(main_path, "templates"), pj(
    forked_repo_path, "templates"),  dirs_exist_ok=True)
shutil.copy(pj(main_path, "scripts", ".SFLB_upstream.config"),
            pj(forked_repo_path, "scripts"))
shutil.copy(pj(main_path, "scripts", "wiadomosci_powitalne.txt"),
            pj(forked_repo_path, "scripts"))
os.replace(pj(forked_repo_path, "scripts", ".SFLB_upstream.config"),
           pj(forked_repo_path, ".SFLB.config"))

os.chdir(forked_repo_path)
os.environ["RTM"] = "true"
os.environ["NO_RM_SFLB_CHANGED_FILES"] = "true"


FILTERLISTS = [pj(forked_repo_path, "cookies_filters", "cookies_uB_AG.txt"), pj(forked_repo_path, "cookies_filters", "adblock_cookies.txt"), pj(
    forked_repo_path,  "adblock_social_filters", "social_filters_uB_AG.txt"), pj(forked_repo_path, "adblock_social_filters", "adblock_social_list.txt")]


forked_git_repo = git.Repo(forked_repo_path, search_parent_directories=True)
forked_git = forked_git_repo.git
cookies_last_update_date = forked_git.log('-1', '--pretty=format:%ct', 'cookies_filters')
social_last_update_date = forked_git.log('-1', '--pretty=format:%ct', 'adblock_social_filters')

last_update_date = ""

if cookies_last_update_date < social_last_update_date:
    last_update_date = cookies_last_update_date
else:
    last_update_date = social_last_update_date

git = git_repo.git
commit_authors_combined = git.log('--pretty=%an <%ae>', '--after', last_update_date, "sections")
commit_authors = sorted(set(commit_authors_combined.splitlines()))
commit_desc = ""

for commit_author in commit_authors:
    if "hawkeye116477" in commit_author:
        commit_author = "hawkeye116477 <19818572+hawkeye116477@users.noreply.github.com>"
    commit_desc += f"\\nCo-authored-by: {commit_author}"

with open(pj(forked_repo_path, ".SFLB.config"), "r", encoding='utf-8') as forked_config_content, NamedTemporaryFile(dir=forked_repo_path, delete=False, mode="w", encoding='utf-8') as f_out:
    for line in forked_config_content:
        line = line.strip()
        if "@commitDesc" in line:
            line = f"@commitDesc {commit_desc}"
        if line:
            f_out.write(f"{line}\n")
os.replace(f_out.name, pj(forked_repo_path, ".SFLB.config"))

SFLB.main(FILTERLISTS, "", "true")
SFLB.doItAgainIfNeed(FILTERLISTS)
SFLB.push(FILTERLISTS)

SFLB_CHANGED_FILES_FILE = pj(
    forked_repo_path, "changed_files", "SFLB_CHANGED_FILES.txt")

updated_filterlists = []

with open(SFLB_CHANGED_FILES_FILE, "r", encoding='utf-8') as sflb_changed_content:
    for line in sflb_changed_content:
        if "adblock_social_filters" in line and "👍🏻" not in updated_filterlists:
            updated_filterlists.append("👍🏻")
        if "cookies_filters" in line and "🍪" not in updated_filterlists:
            updated_filterlists.append("🍪")

if not "RTM_PR_MESSAGE" in os.environ:
    with open(pj(forked_repo_path, "scripts", "wiadomosci_powitalne.txt"), "r") as f:
        lines = f.readlines()
        os.environ["RTM_PR_MESSAGE"] = random.choice(lines)

updated_filterlists_combined = ' & '.join(updated_filterlists)
today = datetime.now().astimezone()
RTM_PR_TITLE = f"Update {updated_filterlists_combined} ({today.year}{
    today.month:02d}{today.day:02d})"

# Wysyłanie PR do upstream
forked_git.clean('-xdf')
print("Teraz otwórz następujący adres w przeglądarce, by wysłać PR:")
print(f"https://github.com/MajkiIT/polish-ads-filter/compare/master...PolishRoboDogHouse:polish-ads-filter:RTM?expand=1&title={urllib.parse.quote(RTM_PR_TITLE)}")

# if "CI" in os.environ:
#     print("Wysyłanie PR...")
#     auth = Auth.Token(os.environ["PR_TOKEN"])
#     g = Github(auth=auth)
#     repo = g.get_repo("MajkiIT/polish-ads-filter")
#     pr = repo.create_pull(base="master", head="PolishRoboDogHouse:RTM",
#                           title=RTM_PR_TITLE, body=os.environ["RTM_PR_MESSAGE"])
#     print(f"https://github.com/MajkiIT/polish-ads-filter/pull/{pr.number}")
# else:
#     user_input = input("Czy chcesz teraz wysłać PR do upstream? (tak/nie)")
#     if user_input.lower() in ["tak", "t"]:
#         extended_desc = input(
#             "Podaj rozszerzony opis PR, np 'Fix #1, fix #2' (bez ciapek; jeśli nie chcesz rozszerzonego opisu, to możesz po prostu nic nie wpisywać): ")
#         subprocess.run(["gh", "pr", "create", "-B", "master", "-H", "RTM", "-R",
#                        "MajkiIT/polish-ads-filter", "--title", RTM_PR_TITLE, "--body", extended_desc])
