(define
    (domain order-pizza)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_pizza_flavour)
        (maybe-have_pizza_flavour)
        (have_drink)
        (maybe-have_drink)
        (have_side)
        (maybe-have_side)
        (goal)
        (end)
        (have-message)
        (force-statement)
    )
    (:action force-all
        :parameters()
        :precondition
            (and
                (not (maybe-have_side))
                (not (have_side))
                (not (have_drink))
                (not (maybe-have_pizza_flavour))
                (not (have_pizza_flavour))
                (not (force-statement))
                (not (maybe-have_drink))
            )
        :effect
            (labeled-oneof validate
                (outcome valid
                    (and
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (have_drink)
                (not (maybe-have_side))
                (not (maybe-have_pizza_flavour))
                (have_pizza_flavour)
                (have_side)
                (not (force-statement))
                (not (maybe-have_drink))
            )
        :effect
            (labeled-oneof finish
                (outcome assign-goal
                    (and
                        (end)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action end
        :parameters()
        :precondition
            (and
                (end)
                (not (force-statement))
            )
        :effect
            (labeled-oneof finish
                (outcome assign-goal
                    (and
                        (goal)
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
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action clarify__pizza_flavour
        :parameters()
        :precondition
            (and
                (maybe-have_pizza_flavour)
                (not (have_pizza_flavour))
                (not (force-statement))
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                    )
                )
                (outcome deny
                    (and
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action clarify__drink
        :parameters()
        :precondition
            (and
                (not (have_drink))
                (not (force-statement))
                (maybe-have_drink)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                    )
                )
                (outcome deny
                    (and
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action clarify__side
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (maybe-have_side)
                (not (have_side))
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                    )
                )
                (outcome deny
                    (and
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
)