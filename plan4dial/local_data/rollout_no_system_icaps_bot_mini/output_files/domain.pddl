(define
    (domain order-pizza)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__invited-talk)
        (know__morning-session)
        (know__afternoon-session)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action get-invited
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__invited-talk))
            )
        :effect
            (labeled-oneof         set-invited-talk
                (outcome valid
                    (and
                        (know__invited-talk)
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
    (:action get-morning
        :parameters()
        :precondition
            (and
                (not (know__morning-session))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         set-morning-session
                (outcome valid
                    (and
                        (know__morning-session)
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
    (:action get-afternoon
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__afternoon-session))
            )
        :effect
            (labeled-oneof         set-afternoon-session
                (outcome valid
                    (and
                        (know__afternoon-session)
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
                (not (force-statement))
                (know__invited-talk)
                (know__morning-session)
                (know__afternoon-session)
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
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof         reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
)