"""
file: setup.py

description: script to build the Cython components.
"""

if __name__ == "__main__":
    import platform
    import setuptools

    import Cython.Build

    kwargs = {
        "extra_compile_args": ["/O2"] if platform.system() == "Windows" else ["-O3"],
    }

    directives = {
        "boundscheck": False,
        "wraparound": False,
        "initializedcheck": False,
        "nonecheck": False,
        "overflowcheck": False,
        "cdivision": False,
        "infer_types": False
    }

    setuptools.setup(
        ext_modules=Cython.Build.cythonize(
            [setuptools.extension.Extension(
                name="board",
                sources=["board.pyx"],
                **kwargs
            ), setuptools.extension.Extension(
                name="evaluate",
                sources=["evaluate.pyx"],
                **kwargs
            ), setuptools.extension.Extension(
                name="search",
                sources=["search.pyx"],
                **kwargs
            )],
            nthreads=8,
            annotate=True,
            compiler_directives=directives
        )
    )
