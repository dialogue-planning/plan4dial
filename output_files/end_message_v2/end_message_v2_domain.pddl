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
                (not (have_drink))
                (not (have_side))
                (not (maybe-have_side))
                (not (force-statement))
                (not (have_pizza_flavour))
                (not (maybe-have_drink))
                (not (maybe-have_pizza_flavour))
            )
        :effect
            (labeled-oneof validate
                (outcome valid
                    (and
                        (not (maybe-have_side))
                        (have_drink)
                        (have_side)
                        (not (maybe-have_drink))
                        (have_pizza_flavour)
                        (not (maybe-have_pizza_flavour))
                    )
                )
                (outcome fallback
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
                (not (end))
                (not (force-statement))
                (not (maybe-have_side))
                (have_drink)
                (have_side)
                (not (maybe-have_drink))
                (have_pizza_flavour)
                (not (maybe-have_pizza_flavour))
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
                (have-message)
                (force-statement)
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
                (not (force-statement))
                (not (have_pizza_flavour))
                (maybe-have_pizza_flavour)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (have_pizza_flavour)
                        (not (maybe-have_pizza_flavour))
                    )
                )
                (outcome deny
                    (and
                        (not (have_pizza_flavour))
                        (not (maybe-have_pizza_flavour))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action clarify__drink
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_drink))
                (maybe-have_drink)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (have_drink)
                        (not (maybe-have_drink))
                    )
                )
                (outcome deny
                    (and
                        (not (have_drink))
                        (not (maybe-have_drink))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action clarify__side
        :parameters()
        :precondition
            (and
                (maybe-have_side)
                (not (force-statement))
                (not (have_side))
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (have_side)
                        (not (maybe-have_side))
                    )
                )
                (outcome deny
                    (and
                        (not (have_side))
                        (not (maybe-have_side))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
)