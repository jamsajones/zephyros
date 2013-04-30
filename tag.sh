#!/usr/bin/env bash

VERSION=$(defaults read $(pwd)/Zephyros/Zephyros-Info CFBundleVersion)
git tag $VERSION
git push --tags
