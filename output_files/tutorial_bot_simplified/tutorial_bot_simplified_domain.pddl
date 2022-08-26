(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (have_restaurant)
        (have_have_allergy)
        (have_allergy)
        (have_food_restriction)
        (have_conflict)
        (conflict)
        (checked-for-conflict)
        (have_low_budget)
        (low_budget)
        (have_outing_atmosphere)
        (goal)
        (have-message)
        (force-statement)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
        (food_restriction-value-dairy-free)
        (food_restriction-value-gluten-free)
    )
    (:action get-cuisine
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-cuisine
                (outcome valid
                    (and
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
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (have_have_allergy))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (conflict))
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
        :precondition
            (and
                (have_allergy)
                (have_have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
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
        :precondition
            (and
                (have_conflict)
                (not (force-statement))
                (conflict)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (conflict))
                    )
                )
            )
    )
    (:action set-restaurant-mexican
        :parameters()
        :precondition
            (and
                (cuisine-value-mexican)
                (have_cuisine)
                (have_conflict)
                (not (conflict))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
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
    (:action set-restaurant-italian
        :parameters()
        :precondition
            (and
                (have_cuisine)
                (have_conflict)
                (cuisine-value-italian)
                (not (conflict))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
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
    (:action set-restaurant-chinese
        :parameters()
        :precondition
            (and
                (have_cuisine)
                (have_conflict)
                (not (conflict))
                (cuisine-value-chinese)
                (not (force-statement))
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
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
    (:action set-restaurant-dessert
        :parameters()
        :precondition
            (and
                (cuisine-value-dessert)
                (have_cuisine)
                (have_conflict)
                (not (conflict))
                (not (force-statement))
            )
        :effect
            (labeled-oneof set
                (outcome valid
                    (and
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
                (have_restaurant)
            )
        :effect
            (labeled-oneof finish
                (outcome finish
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
    (:action check-conflict-1-or-1
        :parameters()
        :precondition
            (and
                (have_allergy)
                (not (force-statement))
                (cuisine-value-mexican)
                (have_have_allergy)
                (food_restriction-value-gluten-free)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                    )
                )
            )
    )
    (:action check-conflict-1-or-2
        :parameters()
        :precondition
            (and
                (have_allergy)
                (food_restriction-value-dairy-free)
                (cuisine-value-dessert)
                (have_have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (conflict)
                    )
                )
            )
    )
    (:action check-conflict-2-or-1
        :parameters()
        :precondition
            (and
                (have_allergy)
                (have_food_restriction)
                (cuisine-value-italian)
                (have_have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-2
        :parameters()
        :precondition
            (and
                (have_allergy)
                (have_food_restriction)
                (have_have_allergy)
                (cuisine-value-chinese)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-3
        :parameters()
        :precondition
            (and
                (have_allergy)
                (food_restriction-value-dairy-free)
                (cuisine-value-mexican)
                (have_have_allergy)
                (not (force-statement))
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                    )
                )
            )
    )
    (:action check-conflict-2-or-4
        :parameters()
        :precondition
            (and
                (have_allergy)
                (not (force-statement))
                (cuisine-value-dessert)
                (have_have_allergy)
                (food_restriction-value-gluten-free)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome validate-combos
                    (and
                        (not (conflict))
                    )
                )
            )
    )
    (:action reset-cuisine-value-mexican
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-mexican)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-mexican
                    (and
                        (not (cuisine-value-mexican))
                    )
                )
            )
    )
    (:action reset-cuisine-value-italian
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-italian)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-italian
                    (and
                        (not (cuisine-value-italian))
                    )
                )
            )
    )
    (:action reset-cuisine-value-chinese
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-chinese)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-chinese
                    (and
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action reset-cuisine-value-dessert
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (cuisine-value-dessert)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-dessert
                    (and
                        (not (cuisine-value-dessert))
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (cuisine-value-chinese))
                (not (cuisine-value-dessert))
                (have_cuisine)
                (not (cuisine-value-italian))
                (not (cuisine-value-mexican))
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
    (:action reset-food_restriction-value-dairy-free
        :parameters()
        :precondition
            (and
                (food_restriction-value-dairy-free)
                (not (have_food_restriction))
            )
        :effect
            (labeled-oneof reset
                (outcome reset-dairy-free
                    (and
                        (not (food_restriction-value-dairy-free))
                    )
                )
            )
    )
    (:action reset-food_restriction-value-gluten-free
        :parameters()
        :precondition
            (and
                (not (have_food_restriction))
                (food_restriction-value-gluten-free)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-gluten-free
                    (and
                        (not (food_restriction-value-gluten-free))
                    )
                )
            )
    )
    (:action set-food_restriction
        :parameters()
        :precondition
            (and
                (have_food_restriction)
                (not (food_restriction-value-gluten-free))
                (not (food_restriction-value-dairy-free))
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
)