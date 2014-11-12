.. -*- coding: utf-8 -*-

==============================================================
Makefiles for data analysis and data driven langevin equations
==============================================================
:Author: Bjoern Bastian

.. Contents::

To read this file as html, call ``make doc``.

This is not yet supposed to be a full documentation but rather
a minimal guideline for typical usage of the scripts provided.

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

Workflow for the main directory
===============================
In contrast to the workflow described here, subdirectories of ``standalone/``
are supposed to be used to apply one analysis to data files as they are.

- Obtain a new clone of the repository as main directory::

    git clone git://github.com/basbjo/ddlangevin_make name_of_working_directory

Makefile information and configuration
--------------------------------------

- To verify the configuration and selected data, use the makefile targets
  ``show`` or ``showconf``, ``showdata`` and ``showmacros`` in any directory.

- Get a target description with ``make info`` and use ``make -n [target]``
  to see what make will do when calling a specific target.

Configuration
-------------

- Select a series of transformations by setting ``projtargets`` in
  ``config.mk``.  Currently, ``colselect``, ``cossin``, ``pca`` and ``tica``
  are available.  The first two may be considered as preprocessing, the latter
  as final transformations.  If ``projtargets`` is empty, further analysis is
  applied directly on the data.  To select ``tica``, consider calling::

    git merge origin/tica

  which adds a few further changes instead of setting ``projtargets`` manually.

  ========== ================================================================ ======
  Target     Description                                                      Suffix
  ========== ================================================================ ======
  colselect  Select a range of columns.                                       .ic
  cossin     Select a range of columns and write out cos- and sin-transforms. .cs
  pca        Apply principal component analysis (PCA).                        .pca
  tica       Apply time-lagged independent component analysis (TICA).         .tica
  ========== ================================================================ ======

  To apply a dihedral PCA (dPCA), set ``projtargets = cossin pca``.
  The suffix of the dPCA projected data will then be ``.cs.pca``.

- Put source data (dihedral angles) into main directory and define
  ``TIME_UNIT``, the wildcard ``RAWDATA`` for source data and the
  ``IF_FUTURE`` value in ``config.mk`` as described there.

- For ``colselect`` and ``cossin``, select the first and last column of the
  source data to be considered as ``MIN_COL`` and ``MAX_COL`` in ``config.mk``.

- For ``tica``, select ``LAG_TIMES`` (unit: time frames) in ``config.mk``.

Data projection
---------------

- Perform transformations to obtain projected data to work with::

    make

- Split projected trajectories before calculating histograms/correlations/etc.::

    make split

Analysis in the main directory
------------------------------

Subdirectories besides ``histogram`` and ``correlation`` may be used likewise.

- To generate histograms, you may first calculate and then plot them::

    cd histogram/
    make calc
    make plot

  If this does not work, you probably have to call the ``split`` or ``minmax``
  target in the main directory (the ``minmax`` file is used to define
  compareable bins).

- To generate correlations, you may first calculate and then plot them::

    cd ../correlation/
    make estim
    make calc #alternatively make plot
    make plot_all

  If this does not work, you probably have to call the ``split`` target in
  the main directory.  Note that the target ``estim`` must be finished before
  calling ``calc`` and the latter before calling ``plot_all``.

- To recreate plots after changes in ``config.mk`` in main directory, call::

    make del_plots; make plot_all

  For convenience, the ``plot_all`` target should always exist even
  if it is equivalent to the ``plot`` target.

Fast data projection and analysis
---------------------------------

- You can project data and (partially) calculate results in the subdirectories
  ``histogram`` and ``correlation`` with a oneliner::

    make; make split; make correlation histogram

  where it may be convenient to use ``-j [number]`` for parallelization.
  The default make target is called in each subdirectory.
  If plots and maybe other targets shall be created with the same call, add
  the wished targets to the variable ``all`` in the subdirectory makefiles.
  However, in ``correlation`` it is necessary to finish the target ``estim``
  before calling ``calc`` and to finish the latter before calling ``plot_all``.

Downsampling (optional)
-----------------------

- To obtain a set of down sampled projected trajectories including trajectories
  with all possible starting points, set ``REDUCTION_FACTORS`` in ``config.mk``
  and call::

    make downsampling

  Sets of trajectories with one starting point are saved in ``downsampling/``.

  Down sampled data is by default taken into account by the ``split`` target
  but ignored in the subdirectories ``histogram/`` and ``correlation/``, see
  ``DATA_LINK`` in the subdirectory makefiles.

Analysis of derived data such as data-driven Langevin equations
---------------------------------------------------------------

- Go to directory ``langevin/`` and usually make a copy of ``template/``::

    cd langevin/
    cp -r template/ new_data/
    cd new_data/

- Create links to projected data and optionally create files with few columns::

    make
    make file.3cols # example to extract 3 columns from file

  When extracting columns, the last column is kept as well if ``IF_FUTURE=1``.

- Provide derived data files and update ``localconf.mk``, for example::

    SPLIT_LIST = *.lang
    SPLIT_FUTURE = 1

  for filenames with the suffix ``.lang`` and if the last column is 1 or 0 to
  denote ends of consecutive trajectories (else set ``SPLIT_FUTURE=0``).

  Filenames must start with exact names of the projected data files and may
  contain additional information before the suffix.

- Split trajectories by calling ``make`` or ``make split``::

    make split

- To generate histograms, you may first calculate and then plot them::

    cd histogram/
    make calc
    make plot

  If this does not work, you probably have to call the ``split`` target
  in the parent directory or ``minmax`` in the main directory (the ``minmax``
  file is used to define compareable bins).

  If a similar histogram file exists in the ``histogram/`` subdirectory of
  the main directory, it is used as reference file to set plot ranges.
  In case no exactly matching reference file is found, also filenames with
  different time steps are tried as a reference which is useful when working
  on down sampled data.

- To generate correlations, you may first calculate and then plot them::

    cd ../correlation/
    make estim
    make calc #alternatively make plot
    make plot_all

  If this does not work, you probably have to call the ``split`` target in
  the parent directory.  Note that the target ``estim`` must be finished before
  calling ``calc`` and the latter before calling ``plot_all``.

- To recreate plots after changes in ``config.mk`` or when new reference
  data is provided in the main directory, call::

    make del_plots; make plot_all

  For convenience, the ``plot_all`` target should always exist even
  if it is equivalent to the ``plot`` target.

- Subdirectories besides ``histogram`` and ``correlation`` may be used
  likewise.  Use ``make info`` and ``make show`` to see what will happen.

- You can split data into single trajectories and calculate results in the
  subdirectories ``histogram`` and ``correlation`` with a oneliner::

    make split; make correlation histogram

  where it may be convenient to use ``-j [number]`` for parallelization.
  The default make target is called in each subdirectory.
  If plots and maybe other targets shall be created with the same call, add
  the wished targets to the variable ``all`` in the subdirectory makefiles.
  However, in ``correlation`` it is necessary to finish the target ``estim``
  before calling ``calc`` and to finish the latter before calling ``plot_all``.
