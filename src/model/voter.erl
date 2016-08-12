-module(voter, [Id, FirstName, LastName, Address, Notes, WardBossId]).
-compile(export_all).

-belongs_to(ward_boss).