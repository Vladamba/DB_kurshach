DROP PROCEDURE IF EXISTS get_products_by_category_id;
DELIMITER $$

CREATE PROCEDURE get_products_by_category_id(IN initial_category_id INT)
BEGIN
  WITH RECURSIVE all_categories(id) AS (
    SELECT id
    FROM categories
    WHERE id = initial_category_id
    UNION ALL
    SELECT c.id
    FROM categories c
    INNER JOIN all_categories ac ON c.parent_id = ac.id
  )

  SELECT DISTINCT p.*
  FROM products p
  INNER JOIN m2m_category_product mcp ON p.id = mcp.product_id
  WHERE mcp.category_id IN (SELECT id FROM all_categories);
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS check_product_price_before_insert;

DELIMITER $$

CREATE TRIGGER check_product_price_before_insert
BEFORE INSERT ON product_prices
FOR EACH ROW
BEGIN
    IF NEW.value < 0
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price is incorrect';
    END IF;
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS check_product_price_before_update;

DELIMITER $$

CREATE TRIGGER check_product_price_before_update
BEFORE UPDATE ON product_prices
FOR EACH ROW
BEGIN
    IF NEW.value < 0
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price is incorrect';
    END IF;
END $$

DELIMITER ;
