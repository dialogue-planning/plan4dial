(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__cuisine)
        (know__restaurant)
        (know__have_allergy)
        (have_allergy)
        (know__food_restriction)
        (know__conflict)
        (conflict)
        (know__low_budget)
        (low_budget)
        (know__outing_atmosphere)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (food_restriction-value-dairy-free)
        (food_restriction-value-gluten-free)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
    )
    (:action get-have-allergy
        :parameters()
        (:precondition
            (and
                (not (force-statement))
                (not (know__have_allergy))
            )
        )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (know__have_allergy)
                        (have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (know__have_allergy)
                        (not (conflict))
                        (know__conflict)
                        (not (have_allergy))
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
    (:action get-allergy
        :parameters()
        (:precondition
            (and
                (know__have_allergy)
                (not (force-statement))
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
                        (know__food_restriction)
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
    (:action reset-preferences
        :parameters()
        (:precondition
            (and
                (not (force-statement))
                (conflict)
                (know__conflict)
            )
        )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (food_restriction-value-gluten-free))
                        (not (cuisine-value-mexican))
                        (have-message)
                        (not (know__food_restriction))
                        (not (know__cuisine))
                        (force-statement)
                        (not (cuisine-value-chinese))
                        (not (know__conflict))
                        (not (food_restriction-value-dairy-free))
                        (not (know__have_allergy))
                        (not (cuisine-value-dessert))
                        (not (cuisine-value-italian))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        (:precondition
            (and
                (not (conflict))
                (know__cuisine)
                (not (force-statement))
                (not (know__restaurant))
                (know__conflict)
            )
        )
        :effect
            (labeled-oneof assign_restaurant
                (outcome set-mexican
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (know__restaurant)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        (:precondition
            (and
                (know__restaurant)
                (not (force-statement))
            )
        )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (goal)
                        (know__goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        (:precondition
            (and
                (have-message)
                (force-statement)
            )
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
    (:action slot-fill__get-cuisine
        :parameters()
        (:precondition
            (and
                (not (force-statement))
                (not (know__cuisine))
            )
        )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome cuisine_found
                    (and
                        (know__cuisine)
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
    (:action check-conflict-1-or-1
        :parameters()
        (:precondition
            (and
                (food_restriction-value-gluten-free)
                (cuisine-value-mexican)
                (know__have_allergy)
                (not (force-statement))
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
            )
    )
    (:action check-conflict-1-or-2
        :parameters()
        (:precondition
            (and
                (food_restriction-value-dairy-free)
                (know__have_allergy)
                (not (force-statement))
                (cuisine-value-dessert)
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-1
        :parameters()
        (:precondition
            (and
                (know__food_restriction)
                (cuisine-value-italian)
                (know__have_allergy)
                (not (force-statement))
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-2
        :parameters()
        (:precondition
            (and
                (know__food_restriction)
                (cuisine-value-chinese)
                (know__have_allergy)
                (not (force-statement))
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-3
        :parameters()
        (:precondition
            (and
                (cuisine-value-mexican)
                (food_restriction-value-dairy-free)
                (know__have_allergy)
                (not (force-statement))
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-4
        :parameters()
        (:precondition
            (and
                (food_restriction-value-gluten-free)
                (know__have_allergy)
                (not (force-statement))
                (cuisine-value-dessert)
                (have_allergy)
            )
        )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action set-food_restriction
        :parameters()
        (:precondition
            (and
                (know__food_restriction)
                (not (food_restriction-value-gluten-free))
                (not (food_restriction-value-dairy-free))
            )
        )
        :effect
            (labeled-oneof set-valid-value
                (outcome dairy-free
                    (and
                        (food_restriction-value-dairy-free)
                    )
                )
                (outcome gluten-free
                    (and
                        (food_restriction-value-gluten-free)
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters()
        (:precondition
            (and
                (not (cuisine-value-mexican))
                (not (cuisine-value-chinese))
                (know__cuisine)
                (not (cuisine-value-dessert))
                (not (cuisine-value-italian))
            )
        )
        :effect
            (labeled-oneof set-valid-value
                (outcome mexican
                    (and
                        (cuisine-value-mexican)
                    )
                )
                (outcome italian
                    (and
                        (cuisine-value-italian)
                    )
                )
                (outcome chinese
                    (and
                        (cuisine-value-chinese)
                    )
                )
                (outcome dessert
                    (and
                        (cuisine-value-dessert)
                    )
                )
            )
    )
)