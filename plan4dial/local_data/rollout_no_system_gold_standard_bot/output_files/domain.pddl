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
            (labeled-oneof         get-base__set-base
                (outcome valid
                    (and
                        (know__base)
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
    (:action get-toppings
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__toppings))
            )
        :effect
            (labeled-oneof         get-toppings__set-toppings
                (outcome valid
                    (and
                        (know__toppings)
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
    (:action get-size
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__size))
            )
        :effect
            (labeled-oneof         get-size__set-size
                (outcome valid
                    (and
                        (know__size)
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
    (:action get-drink
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__drink))
            )
        :effect
            (labeled-oneof         get-drink__set-drink
                (outcome valid
                    (and
                        (know__drink)
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
    (:action get-side
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__side))
            )
        :effect
            (labeled-oneof         get-side__set-side
                (outcome valid
                    (and
                        (know__side)
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
                (know__drink)
                (not (force-statement))
                (know__toppings)
                (know__base)
                (know__size)
                (know__side)
            )
        :effect
            (labeled-oneof         complete__goal
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
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof         dialogue_statement__reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
)