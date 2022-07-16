(define
    (domain order-pizza)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (goal)
        (have-message)
        (force-statement)
        (can-do_ask-location)
        (can-do_ask-order)
        (can-do_dialogue_statement)
        (can-do_clarify__ask-order)
    )
    (:action ask-location
        :parameters()
        :precondition
            (and
                (not (have_start_location))
                (not (maybe-have_start_location))
                (not (have_end_location))
                (not (maybe-have_end_location))
                (not (['force-statement', False]))
                (can-do_ask-location)
            )
        :effect
            (labeled-oneof validate-location
                (outcome ask-location_DETDUP_validate-location-EQ-valid
                    (and
                        (have_start_location)
                        (not (maybe-have_start_location))
                        (have_end_location)
                        (not (maybe-have_end_location))
                    )
                )
                (outcome ask-location_DETDUP_validate-location-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action ask-order
        :parameters()
        :precondition
            (and
                (not (have_order))
                (not (maybe-have_order))
                (not (['force-statement', False]))
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
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (['have-message', True])
                (not (['force-statement', False]))
            )
        :effect
            (labeled-oneof reset
                (outcome dialogue_statement_DETDUP_reset-EQ-lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
                (outcome dialogue_statement_DETDUP_reset-EQ-fallback
                    (and
                        (have-message)
                        (force-statement)
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
                (not (['force-statement', False]))
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
)