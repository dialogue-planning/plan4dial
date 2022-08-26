(define
    (domain order-pizza)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_base)
        (have_size)
        (have_toppings)
        (have_drink)
        (have_side)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action get-base
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_base))
            )
        :effect
            (labeled-oneof set-base
                (outcome valid
                    (and
                        (have_base)
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
    (:action get-toppings
        :parameters()
        :precondition
            (and
                (not (have_toppings))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-toppings
                (outcome valid
                    (and
                        (have_toppings)
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
    (:action get-size
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_size))
            )
        :effect
            (labeled-oneof set-size
                (outcome valid
                    (and
                        (have_size)
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
    (:action get-drink
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_drink))
            )
        :effect
            (labeled-oneof set-drink
                (outcome valid
                    (and
                        (have_drink)
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
    (:action get-side
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_side))
            )
        :effect
            (labeled-oneof set-side
                (outcome valid
                    (and
                        (have_side)
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
                (have_size)
                (have_side)
                (have_base)
                (not (force-statement))
                (have_drink)
                (have_toppings)
            )
        :effect
            (labeled-oneof goal
                (outcome valid
                    (and
                        (goal)
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
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
)