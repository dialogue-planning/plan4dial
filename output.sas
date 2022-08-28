begin_version
3
end_version
begin_metric
0
end_metric
16
begin_variable
var0
-1
2
Atom food_restriction-value-dairy-free()
NegatedAtom food_restriction-value-dairy-free()
end_variable
begin_variable
var1
-1
2
Atom food_restriction-value-gluten-free()
NegatedAtom food_restriction-value-gluten-free()
end_variable
begin_variable
var2
-1
2
Atom have_allergy()
NegatedAtom have_allergy()
end_variable
begin_variable
var3
-1
2
Atom have_cuisine()
NegatedAtom have_cuisine()
end_variable
begin_variable
var4
-1
2
Atom cuisine-value-chinese()
NegatedAtom cuisine-value-chinese()
end_variable
begin_variable
var5
-1
2
Atom cuisine-value-dessert()
NegatedAtom cuisine-value-dessert()
end_variable
begin_variable
var6
-1
2
Atom cuisine-value-italian()
NegatedAtom cuisine-value-italian()
end_variable
begin_variable
var7
-1
2
Atom cuisine-value-mexican()
NegatedAtom cuisine-value-mexican()
end_variable
begin_variable
var8
-1
2
Atom have_have_allergy()
NegatedAtom have_have_allergy()
end_variable
begin_variable
var9
-1
2
Atom have_food_restriction()
NegatedAtom have_food_restriction()
end_variable
begin_variable
var10
-1
2
Atom force-statement()
NegatedAtom force-statement()
end_variable
begin_variable
var11
-1
2
Atom conflict()
NegatedAtom conflict()
end_variable
begin_variable
var12
-1
2
Atom have_conflict()
NegatedAtom have_conflict()
end_variable
begin_variable
var13
-1
2
Atom have-message()
NegatedAtom have-message()
end_variable
begin_variable
var14
-1
2
Atom have_restaurant()
NegatedAtom have_restaurant()
end_variable
begin_variable
var15
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
15 0
end_goal
36
begin_operator
check-conflict-1-or-1_DETDUP_check-conflicts-EQ-validate-combos 
5
7 0
1 0
10 1
2 0
8 0
2
0 11 -1 0
0 12 -1 0
1
end_operator
begin_operator
check-conflict-1-or-2_DETDUP_check-conflicts-EQ-validate-combos 
5
5 0
0 0
10 1
2 0
8 0
2
0 11 -1 0
0 12 -1 0
1
end_operator
begin_operator
check-conflict-2-or-1_DETDUP_check-conflicts-EQ-validate-combos 
5
6 0
10 1
2 0
9 0
8 0
2
0 11 -1 1
0 12 -1 0
1
end_operator
begin_operator
check-conflict-2-or-2_DETDUP_check-conflicts-EQ-validate-combos 
5
4 0
10 1
2 0
9 0
8 0
2
0 11 -1 1
0 12 -1 0
1
end_operator
begin_operator
check-conflict-2-or-3_DETDUP_check-conflicts-EQ-validate-combos 
5
7 0
0 0
10 1
2 0
8 0
2
0 11 -1 1
0 12 -1 0
1
end_operator
begin_operator
check-conflict-2-or-4_DETDUP_check-conflicts-EQ-validate-combos 
5
5 0
1 0
10 1
2 0
8 0
2
0 11 -1 1
0 12 -1 0
1
end_operator
begin_operator
complete_DETDUP_finish-EQ-finish 
2
10 1
14 0
1
0 15 -1 0
1
end_operator
begin_operator
dialogue_statement_DETDUP_reset-EQ-lock 
0
2
0 10 0 1
0 13 0 1
1
end_operator
begin_operator
get-allergy_DETDUP_set-allergy-EQ-fallback 
2
2 0
8 0
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
get-allergy_DETDUP_set-allergy-EQ-update_allergy 
3
10 1
2 0
8 0
1
0 9 -1 0
1
end_operator
begin_operator
get-cuisine_DETDUP_set-cuisine-EQ-fallback 
1
3 1
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
get-cuisine_DETDUP_set-cuisine-EQ-valid 
1
10 1
1
0 3 1 0
1
end_operator
begin_operator
get-have-allergy_DETDUP_set-allergy-EQ-fallback 
1
8 1
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
get-have-allergy_DETDUP_set-allergy-EQ-indicate_allergy 
1
10 1
2
0 2 -1 0
0 8 1 0
1
end_operator
begin_operator
get-have-allergy_DETDUP_set-allergy-EQ-indicate_no_allergy 
1
10 1
4
0 11 -1 1
0 2 -1 1
0 12 -1 0
0 8 1 0
1
end_operator
begin_operator
reset-cuisine-value-chinese_DETDUP_reset-EQ-reset-chinese 
1
3 1
1
0 4 0 1
1
end_operator
begin_operator
reset-cuisine-value-dessert_DETDUP_reset-EQ-reset-dessert 
1
3 1
1
0 5 0 1
1
end_operator
begin_operator
reset-cuisine-value-italian_DETDUP_reset-EQ-reset-italian 
1
3 1
1
0 6 0 1
1
end_operator
begin_operator
reset-cuisine-value-mexican_DETDUP_reset-EQ-reset-mexican 
1
3 1
1
0 7 0 1
1
end_operator
begin_operator
reset-food_restriction-value-dairy-free_DETDUP_reset-EQ-reset-dairy-free 
1
9 1
1
0 0 0 1
1
end_operator
begin_operator
reset-food_restriction-value-gluten-free_DETDUP_reset-EQ-reset-gluten-free 
1
9 1
1
0 1 0 1
1
end_operator
begin_operator
reset-preferences_DETDUP_reset-EQ-reset-values 
1
10 1
5
0 11 0 1
0 12 0 1
0 3 -1 1
0 9 -1 1
0 8 -1 1
1
end_operator
begin_operator
set-cuisine_DETDUP_set-valid-value-EQ-chinese 
4
5 1
6 1
7 1
3 0
1
0 4 1 0
1
end_operator
begin_operator
set-cuisine_DETDUP_set-valid-value-EQ-dessert 
4
4 1
6 1
7 1
3 0
1
0 5 1 0
1
end_operator
begin_operator
set-cuisine_DETDUP_set-valid-value-EQ-italian 
4
4 1
5 1
7 1
3 0
1
0 6 1 0
1
end_operator
begin_operator
set-cuisine_DETDUP_set-valid-value-EQ-mexican 
4
4 1
5 1
6 1
3 0
1
0 7 1 0
1
end_operator
begin_operator
set-food_restriction_DETDUP_set-valid-value-EQ-dairy-free 
2
1 1
9 0
1
0 0 1 0
1
end_operator
begin_operator
set-food_restriction_DETDUP_set-valid-value-EQ-gluten-free 
2
0 1
9 0
1
0 1 1 0
1
end_operator
begin_operator
set-restaurant-chinese_DETDUP_set-EQ-fallback 
4
11 1
4 0
12 0
3 0
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
set-restaurant-chinese_DETDUP_set-EQ-valid 
5
11 1
4 0
10 1
12 0
3 0
1
0 14 -1 0
1
end_operator
begin_operator
set-restaurant-dessert_DETDUP_set-EQ-fallback 
4
11 1
5 0
12 0
3 0
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
set-restaurant-dessert_DETDUP_set-EQ-valid 
5
11 1
5 0
10 1
12 0
3 0
1
0 14 -1 0
1
end_operator
begin_operator
set-restaurant-italian_DETDUP_set-EQ-fallback 
4
11 1
6 0
12 0
3 0
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
set-restaurant-italian_DETDUP_set-EQ-valid 
5
11 1
6 0
10 1
12 0
3 0
1
0 14 -1 0
1
end_operator
begin_operator
set-restaurant-mexican_DETDUP_set-EQ-fallback 
4
11 1
7 0
12 0
3 0
2
0 10 1 0
0 13 -1 0
1
end_operator
begin_operator
set-restaurant-mexican_DETDUP_set-EQ-valid 
5
11 1
7 0
10 1
12 0
3 0
1
0 14 -1 0
1
end_operator
0
