.. -*- coding: utf-8 -*-

==============================================================
Makefiles for data analysis and data driven langevin equations
==============================================================
:Author: Bjoern Bastian

.. Contents::

Writing new makefiles
=====================
- Create a topic directory, e.g. ``topic``.
- Copy ``makefiles/Makefile.template`` to ``topic/Makefile`` and set ``prefix``.
- Make a copy of ``template.mk`` in ``makefiles``, e.g. ``topic.mk``.
- Make a first git commit with a message ``topic: Basic structure``.
- Adjust ``datadirs`` and include directives in ``topic/Makefile``.
- Optionally write scripts, e.g. ``makefiles/scripts/scriptname.sh``.
- Define targets, rules, macros and default settings in ``makefiles/topic.mk``.
- In a makefile scripts are called as ``$(SCR)/scriptname.sh``.
- In a script another script is called as ``${scripts}/scriptname.sh``.
- Update ``INFO``, ``INFOend`` and ``INFOADD`` in ``makefiles/topic.mk``.
- Foreach target in ``INFO`` or ``INFOend``, define a description ``INFO_target``.
- Set default targets and optionally define settings in ``topic/Makefile``.
