#!/usr/bin/env python3
# coding=utf-8
# pylint: disable=C0103
# pylint: disable=no-member
# pylint: disable=anomalous-backslash-in-string
# pylint: disable=missing-class-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=line-too-long
#
import argparse
import os
from github import Auth
from github import Github
from github import GithubIntegration


parser = argparse.ArgumentParser()
parser.add_argument('--body', type=str, action='store')
parser.add_argument('--title', type=str, action='store')
args = parser.parse_args()

auth = Auth.Token(os.environ["PR_TOKEN"])
g = Github(auth=auth)
repo = g.get_repo("MajkiIT/polish-ads-filter")
print(args.title)
print(args.body)
# pr = repo.create_pull(base="master", head="PolishRoboDogHouse:RTM", title=args.title, body=args.body)
