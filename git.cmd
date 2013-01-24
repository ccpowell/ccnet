@rem Do not use "echo off" to not affect any child calls.
@setlocal

@set HOME=C:\Build\Config

@set PLINK_PROTOCOL=ssh

@"C:\Program Files (x86)\Git\bin\git.exe" %*
