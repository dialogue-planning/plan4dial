(define
    (domain order-pizza)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_order)
        (maybe-have_order)
        (have_drink)
        (maybe-have_drink)
        (have_side)
        (maybe-have_side)
        (goal)
        (have-message)
        (force-statement)
        (can-do_ask-order)
        (can-do_ask-drink)
        (can-do_ask-side)
        (can-do_dialogue_statement)
        (can-do_clarify__ask-order)
        (can-do_clarify__ask-side)
    )
    (:action ask-order
        :parameters()
        :precondition
            (and
                (not (have_order))
                (not (maybe-have_order))
                (not (force-statement))
                (can-do_ask-order)
            )
        :effect
            (labeled-oneof validate-response
                (outcome ask-order_DETDUP_validate-response-EQ-valid
                    (and
                        (have_order)
                        (not (maybe-have_order))
                    )
                )
                (outcome ask-order_DETDUP_validate-response-EQ-unclear
                    (and
                        (not (have_order))
                        (maybe-have_order)
                    )
                )
                (outcome ask-order_DETDUP_validate-response-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action ask-drink
        :parameters()
        :precondition
            (and
                (have_order)
                (not (maybe-have_order))
                (not (have_drink))
                (not (maybe-have_drink))
                (not (force-statement))
                (can-do_ask-drink)
            )
        :effect
            (labeled-oneof validate-order
                (outcome ask-drink_DETDUP_validate-order-EQ-valid
                    (and
                        (have_drink)
                        (not (maybe-have_drink))
                        (goal)
                    )
                )
                (outcome ask-drink_DETDUP_validate-order-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action ask-side
        :parameters()
        :precondition
            (and
                (have_order)
                (not (maybe-have_order))
                (not (have_side))
                (not (maybe-have_side))
                (not (force-statement))
                (can-do_ask-side)
            )
        :effect
            (labeled-oneof validate-response
                (outcome ask-side_DETDUP_validate-response-EQ-valid
                    (and
                        (have_side)
                        (not (maybe-have_side))
                    )
                )
                (outcome ask-side_DETDUP_validate-response-EQ-unclear
                    (and
                        (not (have_side))
                        (maybe-have_side)
                    )
                )
                (outcome ask-side_DETDUP_validate-response-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof reset
                (outcome dialogue_statement_DETDUP_reset-EQ-lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action clarify__ask-order
        :parameters()
        :precondition
            (and
                (not (have_order))
                (maybe-have_order)
                (not (force-statement))
                (can-do_clarify__ask-order)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome clarify__ask-order_DETDUP_validate-clarification-EQ-confirm
                    (and
                        (have_order)
                        (not (maybe-have_order))
                    )
                )
                (outcome clarify__ask-order_DETDUP_validate-clarification-EQ-deny
                    (and
                        (not (have_order))
                        (not (maybe-have_order))
                    )
                )
                (outcome clarify__ask-order_DETDUP_validate-clarification-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action clarify__ask-side
        :parameters()
        :precondition
            (and
                (not (have_side))
                (maybe-have_side)
                (not (force-statement))
                (can-do_clarify__ask-side)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome clarify__ask-side_DETDUP_validate-clarification-EQ-confirm
                    (and
                        (have_side)
                        (not (maybe-have_side))
                    )
                )
                (outcome clarify__ask-side_DETDUP_validate-clarification-EQ-deny
                    (and
                        (not (have_side))
                        (not (maybe-have_side))
                    )
                )
                (outcome clarify__ask-side_DETDUP_validate-clarification-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
)