@ECHO OFF
ECHO ��������� ���� ����� ����� �������� ���������
FOR /l %%a in (120,-1,1) do (TITLE %title% -- ���� ���� ��������� ����� %%a c&ping -n 2 -w 1 127.0.0.1>NUL&echo|set /p=.)