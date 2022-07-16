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
Atom have_drink()
NegatedAtom have_drink()
end_variable
begin_variable
var1
-1
2
Atom have_order()
NegatedAtom have_order()
end_variable
begin_variable
var2
-1
2
Atom maybe-have_order()
NegatedAtom maybe-have_order()
end_variable
begin_variable
var3
-1
2
Atom have_side()
NegatedAtom have_side()
end_variable
begin_variable
var4
-1
2
Atom force-statement()
NegatedAtom force-statement()
end_variable
begin_variable
var5
-1
2
Atom maybe-have_side()
NegatedAtom maybe-have_side()
end_variable
begin_variable
var6
-1
2
Atom have-message()
NegatedAtom have-message()
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
15
begin_operator
ask-drink_DETDUP_validate-order-EQ-ask-drink_detdup_validate-order-eq-fallback 
3
0 1
1 0
2 1
2
0 4 1 0
0 6 -1 0
1
end_operator
begin_operator
ask-drink_DETDUP_validate-order-EQ-ask-drink_detdup_validate-order-eq-valid 
3
4 1
1 0
2 1
2
0 7 -1 0
0 0 1 0
1
end_operator
begin_operator
ask-order_DETDUP_validate-response-EQ-ask-order_detdup_validate-response-eq-fallback 
2
1 1
2 1
2
0 4 1 0
0 6 -1 0
1
end_operator
begin_operator
ask-order_DETDUP_validate-response-EQ-ask-order_detdup_validate-response-eq-unclear 
2
4 1
1 1
1
0 2 1 0
1
end_operator
begin_operator
ask-order_DETDUP_validate-response-EQ-ask-order_detdup_validate-response-eq-valid 
2
4 1
2 1
1
0 1 1 0
1
end_operator
begin_operator
ask-side_DETDUP_validate-response-EQ-ask-side_detdup_validate-response-eq-fallback 
4
1 0
3 1
2 1
5 1
2
0 4 1 0
0 6 -1 0
1
end_operator
begin_operator
ask-side_DETDUP_validate-response-EQ-ask-side_detdup_validate-response-eq-unclear 
4
4 1
1 0
3 1
2 1
1
0 5 1 0
1
end_operator
begin_operator
ask-side_DETDUP_validate-response-EQ-ask-side_detdup_validate-response-eq-valid 
4
4 1
1 0
2 1
5 1
1
0 3 1 0
1
end_operator
begin_operator
clarify__ask-order_DETDUP_validate-clarification-EQ-clarify__ask-order_detdup_validate-clarification-eq-confirm 
1
4 1
2
0 1 1 0
0 2 0 1
1
end_operator
begin_operator
clarify__ask-order_DETDUP_validate-clarification-EQ-clarify__ask-order_detdup_validate-clarification-eq-deny 
2
4 1
1 1
1
0 2 0 1
1
end_operator
begin_operator
clarify__ask-order_DETDUP_validate-clarification-EQ-clarify__ask-order_detdup_validate-clarification-eq-fallback 
2
1 1
2 0
2
0 4 1 0
0 6 -1 0
1
end_operator
begin_operator
clarify__ask-side_DETDUP_validate-clarification-EQ-clarify__ask-side_detdup_validate-clarification-eq-confirm 
1
4 1
2
0 3 1 0
0 5 0 1
1
end_operator
begin_operator
clarify__ask-side_DETDUP_validate-clarification-EQ-clarify__ask-side_detdup_validate-clarification-eq-deny 
2
4 1
3 1
1
0 5 0 1
1
end_operator
begin_operator
clarify__ask-side_DETDUP_validate-clarification-EQ-clarify__ask-side_detdup_validate-clarification-eq-fallback 
2
3 1
5 0
2
0 4 1 0
0 6 -1 0
1
end_operator
begin_operator
dialogue_statement_DETDUP_reset-EQ-dialogue_statement_detdup_reset-eq-lock 
0
2
0 4 0 1
0 6 0 1
1
end_operator
0
