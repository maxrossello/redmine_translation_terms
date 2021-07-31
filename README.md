# Redmine Translation Terms

Allows to customize specific terms in Redmine translations, and allows third party plugins to support translations containing customizable terms.
*En*, *en-GB* and *it* locales are supported.

## TL;DR

Redmine uses rather generic terms for the objects it manages (e.g. _issue_, _project_). If you use Redmine for a specific scope, you might want to use more specific terms. For example: _activity_ to replace _issue_, or _workgroup_ to replace _project_. This plugin offers a second layer of translation adding interpolations and related definitions to substitute specific terms.

Several terms are thus made replaceable. Moreover, each language comes with its own set of specific terms, to cope with gender differences impacting surrounding words too (e.g. articles and adjectives in italian).

## Version

Tests are performed through [redmine_testsuites](https://github.com/maxrossello/redmine_testsuites) including all the plugins it supports.

The plugin version corresponds to minimum version of Redmine required. Look at dedicated branch for each Redmine version.

## Overview

Redmine uses terms as generic as possible, like _issue_, to cover all use cases it can manage. However, if you use Redmine for specific purposes, you might like to use different, more specific, terms.

This plugin offers a second layer of translation via files placed under _config/elocales_ (_en_, _en-GB_ and _it_ locales are supported) which override a subset of the terms that come with Redmine. It also provides interpolated terms under _config/overrides/&lt;locale&gt;/001.yml_, containing the default translations as they come from Redmine. So by default, nothing changes.
You can add newer redefinitions of overridden terms in additional files under the same path, in this plugin or in your own preferred one. The interpolated terms files are taken in filename lexical order, so e.g. definitions in *002.yml* will be taken over those of *001.yml*, irrespective of the plugin where they are provided. Of course, overrides under the locale of the current user will be only considered.

Third party plugins can also support flexible translation terms, if they provide *config/elocales* definitions along with *config/locales*, so to support normal translation if this plugin is not installed, or flexible translation if it is.

Note that some locales, like italian, require a different translation of surrounding terms such as articles, adjectives, etc.. Also, some articles are ellipsed if used before terms starting with a vocal letter. Therefore, if you e.g. change a male term into a female one, also those surrounding terms need related translation. For this reason, the elocales are rather different for each language.

## Features

* provide default Redmine translations with interpolations for terms like *issue*, *project*, *status*, etc., and possibly for surrounding words like articles and adjectives when changing the word gender would impact them also
* replace interpolated terms with overrides defined in any plugin. Default overrides match the default Redmine terms
* overriding interpolation files are taken in order according to lexicographic order of the filename. As a convention, *XXX.yml* should be used as a filename, where *XXX* are 3-digit numbers.

## Installation

Place the plugin code under the *plugins* directory and restart your server.

    cd {redmine root}
    git clone https://github.com/maxrossello/redmine_translation_terms.git plugins/translation_terms

## How to customize terms over Redmine translations

* Set the current directory to *config/overrides/&lt;locale&gt;* within this plugin or your own
* Copy the existing *001.yml* to *./XXX.yml*, where *XXX* is a 3-digit number defining the priority of your definitions: the higher number the higher priority. Better to avoid to create *999.yml*, so to leave more space for further overrides.
* Filter out the definitions that you *do not* want to change. This way, a lower priority file will be able to apply its changes for things that you do not want to touch
* Apply your own definitions over remaining terms
* Put any override definition which is not yet foreseen in this plugin into a file _000.yml_ so that it will be replaced by official plugin override when provided

## How to support customizable terms in your plugin

* provide translation files under *config/locales* as usual, for working properly when this plugin is not installed. If you don't, you should require this plugin explicitly in your *init.rb*. See Redmine documentation for more information
* copy your locales under *config/elocales*
* for each overridable term listed in *001.yml*, edit the translations so to apply an interpolation. For example, whenever you print *issue* you should replace the word with *%{issue}*, and whenever you print *issue(s)* you should replace the word with *%{issue_or_issues}*
* you can support more overridable terms in your plugin, but if they are also used in base Redmine, you should add interpolated definitions for Redmine terms also. 
For example, you can support a new *%{my_term}* term in your elocales; if the translation is used in Redmine terms too, then you shall add them to your elocales with proper substitution of *%{my_term}* so that the translation remains consistent
