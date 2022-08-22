begin_version
3
end_version
begin_metric
0
end_metric
8
begin_variable
var0
-1
2
Atom have_cuisine()
NegatedAtom have_cuisine()
end_variable
begin_variable
var1
-1
2
Atom force-statement()
NegatedAtom force-statement()
end_variable
begin_variable
var2
-1
2
Atom have-message()
NegatedAtom have-message()
end_variable
begin_variable
var3
-1
2
Atom can-set-cuisine()
NegatedAtom can-set-cuisine()
end_variable
begin_variable
var4
-1
2
Atom cuisine-value-mexican()
NegatedAtom cuisine-value-mexican()
end_variable
begin_variable
var5
-1
2
Atom cuisine-value-italian()
NegatedAtom cuisine-value-italian()
end_variable
begin_variable
var6
-1
2
Atom test()
NegatedAtom test()
end_variable
begin_variable
var7
-1
2
Atom goal()
NegatedAtom goal()
end_variable
0
begin_state
1
1
1
1
1
1
1
1
end_state
begin_goal
1
7 0
end_goal
8
begin_operator
dialogue_statement_DETDUP_reset-EQ-lock 
0
2
0 1 0 1
0 2 0 1
1
end_operator
begin_operator
get-cuisine_DETDUP_set-cuisine-EQ-fallback 
1
0 1
2
0 1 1 0
0 2 -1 0
1
end_operator
begin_operator
get-cuisine_DETDUP_set-cuisine-EQ-valid 
1
1 1
2
0 3 -1 0
0 0 1 0
1
end_operator
begin_operator
goal1_DETDUP_done-EQ-done 
2
4 0
1 1
1
0 7 -1 0
1
end_operator
begin_operator
goal2_DETDUP_done-EQ-done 
2
1 1
6 0
1
0 7 -1 0
1
end_operator
begin_operator
set-cuisine_DETDUP_set-EQ-valid1 
0
2
0 3 0 1
0 5 -1 0
1
end_operator
begin_operator
set-cuisine_DETDUP_set-EQ-valid2 
0
2
0 3 0 1
0 4 -1 0
1
end_operator
begin_operator
test_value_DETDUP_test-value-EQ-assign 
2
5 0
1 1
1
0 6 -1 0
1
end_operator
0
