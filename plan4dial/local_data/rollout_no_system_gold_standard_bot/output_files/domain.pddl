(define
    (domain order-pizza)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__base)
        (know__size)
        (know__toppings)
        (know__drink)
        (know__side)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action get-base
        :parameters()
        :precondition
            (and
                (not (know__base))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-base
                (outcome valid
                    (and
                        (know__base)
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
                (not (know__toppings))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-toppings
                (outcome valid
                    (and
                        (know__toppings)
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
                (not (know__size))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-size
                (outcome valid
                    (and
                        (know__size)
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
                (not (know__drink))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-drink
                (outcome valid
                    (and
                        (know__drink)
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
                (not (know__side))
            )
        :effect
            (labeled-oneof         set-side
                (outcome valid
                    (and
                        (know__side)
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
                (know__toppings)
                (know__side)
                (know__size)
                (not (force-statement))
                (know__base)
                (know__drink)
            )
        :effect
            (labeled-oneof         goal
                (outcome valid
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
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
)