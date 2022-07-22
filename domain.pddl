(define
    (domain order-pizza)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_order)
        (maybe-have_order)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action ask-order
        :parameters()
        :precondition
            (and
                (not (have_order))
                (not (maybe-have_order))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome ask-order_DETDUP_validate-slot-fill-EQ-order_Certain
                    (and
                        (have_order)
                        (not (maybe-have_order))
                    )
                )
                (outcome ask-order_DETDUP_validate-slot-fill-EQ-order_Uncertain
                    (and
                        (not (have_order))
                        (maybe-have_order)
                    )
                )
                (outcome ask-order_DETDUP_validate-slot-fill-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (not (maybe-have_order))
                (have_order)
            )
        :effect
            (labeled-oneof finish
                (outcome complete_DETDUP_finish-EQ-assign-goal
                    (and
                        (goal)
                    )
                )
                (outcome complete_DETDUP_finish-EQ-fallback
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
                (force-statement)
                (have-message)
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
    (:action clarify__order
        :parameters()
        :precondition
            (and
                (not (have_order))
                (maybe-have_order)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome clarify__order_DETDUP_validate-clarification-EQ-confirm
                    (and
                        (have_order)
                        (not (maybe-have_order))
                    )
                )
                (outcome clarify__order_DETDUP_validate-clarification-EQ-deny
                    (and
                        (not (have_order))
                        (not (maybe-have_order))
                    )
                )
                (outcome clarify__order_DETDUP_validate-clarification-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
)